---
layout: post
title:  "Record at hand"
date:   2024-12-09
categories: blog

---
# 2024/12/10
## C++里声明Q_INVOKABLE宏的函数返回类型不能是QVariant&
在把c++注册成一个qml属性，通过这种方法数据交互。<br>
返回QVariant，会导致copy一遍。但没办法，qml不支持传入引用的参数。qml支持的数据类型太少了。<br>
可能是函数返回到qml里，这个变量内存被释放了。<br>
## C++ 局部变量返回
值没问题，相当于复制一遍。<br>
传指针的话，指针指向的内存已经被释放了，就会报错。<br>
不想copy的话，有以下几种方法：<br>
1. 左值引用
```cpp
void test(std::vector<int> &a)
{
   a = {1, 2, 3};
}
```
接下去几种都能返回指针
2. 局部变量设为智能指针
3. 局部变量设为静态变量
4. 动态分配局部变量（要自己free）
![alt text](/images/image1209.png)



# 2024/12/12
## 智能指针 传参问题 

## trailing return type


# 2024/12/21
## 字符串
c风格字符串 就是 char* 分配大小要考虑\0<br>
c++ std::string 不需要考虑\0，“a"的大小可以为1<br>


# 2025/1/27
## 

# 2025/2/12
## terminal vs shell
这两个是不同的东西。<br>
讲一下terminal.<br>
之前的电脑就像一个打印机，不支持很多方便的交互。做的只是用户输入ASCII码，然后打印输出。<br>
也是处于这个原因，现在c程序打印是行输出，因为当时打印机能做到的只有一行一行打印出来。<br>
现在电脑当然不需要这样的terminal，但是需要一个类似的东西来模拟这种操作。这种东西叫做terminal emulator<br>
终端模拟器会做的事情:提供一个图形界面，包括处理键盘输入，分多个窗口，自定义主题和字体颜色等。然而它不会做对用户输入的解析，它只是一个壳<br>
terminal emulator包括像 windows terminal,Kitty,vs里的terminal之类。<br>
而shell是一个软件<br>
shell包括cmd pwsh fish等<br>
shell被称为repl (read emulate print loop)可见它干的是什么事。<br>
我可以在windows terminal里运行shell.exe,也可以在Kitty里运行。<br>
shell做的很多事都是在调用别的地方的程序。比如 whereis ls 会发现ls的程序路径和shell完全没关系<br>
但是像 |和 > 和 cd 这三个是shell完成的程序。它解析用户的输入，是把上一条命令作为下一条命令的输入，将输入内容写入某个文件，切换到某个路径下<br>

# 2025/2/26
## 最近学会的一些操作
### first
起因:想下载vsix插件，但是插件市场里只支持打开vscode下载，github源码没有vsix文件
1.npm install vsce
2.git clone 项目
3.npm install 
4.vsce package 就能生成vsix文件
### second
学了mermaid，用的是vscode+markdown preview enhanced + markdown preview mermaid support
问题是直接导出pdf的话，无法正常显示mermaid图形，只能通过export chrome png的形式得到图片
