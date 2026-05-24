---
title: "os 6.828 xv6 踩坑&问题记录"
date: 2025-05-06T02:01:58+05:30
description: "主要是通过看xv6的书和做lab来重新学习os,所以记录内容分成两部分：做xv6 2024 lab踩的坑和看xv6 book rev4以及xv6 源码的时候遇到的问题"
tags: [Note]
---

# xv6-2024-lab1-踩坑记录
## pingpong
按照题意，要用单通道完成双向通信。  
出现的问题：父进程可以成功读出，但是子进程的打印内容消失。  
![alt text](/assets/image.png)
原因：有可能是父进程先结束，子进程被强制截止，没有刷新缓冲区  
所以子进程写入完成之后，父进程执行wait()即可  


## primes
![alt text](/assets/image-1.png)
原因：调试发现创建pipe的时候出错了，可能是fd不够用了  
发现原因是我没有在完成读取上一个进程数据之后立马把p0关掉，因此在创建下一个子进程的时候，p0也会被继承；  
出现上一层不用的fd全被之后的子进程继承了，资源就不够了。  
->虽然我在父进程处理完数据之后把p0关掉了，但是不及时。不用的fd应该在第一时间关闭  

## find
![alt text](/assets/image-3.png)
出现问题：调试发现buff溢出不够大了  
原因：fmtname 这个函数在ls.c里的实现为了打印的时候对齐，在文件名后面填充了DIRSIZE-strlen(p)个" "，把这个删掉就好了  

# xv6-2024-chapter1-问题记录
# Chapter 1
## 1.1 process and memory
1. syscall: exit
```cpp
 exit(0) 
 ```
为什么可以直接把返回值写在参数里  
-> 返回值是操作系统接收用的，通过读取返回的状态码确认程序执行到哪里。一般0 indicate 成功，1 indicate失败。 

2. 
```cpp
if(fork1()==0)
runcmd(lcmd->left);
```
runcmd一定是在子进程里执行吗  
->yes,因为 In the original process, fork returns the new process’s PID. In the new process, fork returns zero  .
父进程是不会执行,因为Although the child has the same memory contents as the parent initially, the parent and child are executing with separate memory and separate registers: changing a variable in one does not affect the other. 

3. 
>The exec system call replaces the calling process’s memory with a new memory image loaded from a file stored in the file system.

怎么证明已经replace了  

-> memory image 包括 test segment,data segment,stack segment和heap,这里replace的意思是像 execl("/bin/sleep", "sleep", "5", NULL);会读取这个路径里sleep的elf文件，把当前进程的memory image替换成sleep要的memory image.  
但是不改变这个进程的pid,ppid,fd  
```cpp
if (fork() == 0) {
    // 子进程
    execl("/bin/sleep", "sleep", "5", NULL);
    exit(1);  // exec 失败时退出子进程
} else {
    // 父进程
    wait(NULL);  // 等待子进程结束
    printf("Child finished\n");
}
//如果exec成功，就不会执行exit(1),这个证明exec做了replace。
// 但sleep程序里最后有exit(0)，所以父进程还是能顺利执行wait并打印
```

## 1.2 I/O and File descriptors
1. the essence of the program cat 
```cpp
char buf[512];
int n;

for(;;){
    n=read(0,buf,sizeof(buf));
    if(n==0){//read done
        break;
    }
    if(n<0){
        fprintf(2,"read error\n");
        exit(1);
    }
    if(write(1,buf,n)!=n){
        fprintf(2,"write error\n");
        exit(1);
    }
}
```
对于cat来说，它不知道0具体是a file ,console or a pipe，只知道是input；1 它也只知道是output；不知道是std out 还是被 i/o redirection过。
2. shell 重定向的实现
```cpp
//cat < input.txt:
char *argv[2];
argv[0] = "cat";
argv[1] = 0;
if(fork() == 0) {
close(0);
open("input.txt", O_RDONLY);
exec("cat", argv);
}
```
  *  fork会复制父进程的file descriptor table,so that the child starts with exactly the same open files as the parent.
  *  close做的事情：release open file fd ，make it free for reuse
  *  open做的事情：open is guaranteed to use that file descriptor for the newly opened input.txt: 0 will be the smallest available file descriptor. 所以成功设置input.txt是0
  *  exec虽然会替换后面的memory image,但是会保留当前的file table.所以input.txt fd还是0
  *  对于cat来说只会读fd：0



3. 
> Internally, the xv6 kernel uses the file descriptor as an index into a per-process table, so that every process has a private space of file descriptors starting at zero  

这句话啥意思  
<br>->每一个进程都有自己的fd表，0是stdin,1是stdout,2是stderr，3开始是别的打开的文件。a.txt在进程1里fd可能是4，在进程2里可能是7  