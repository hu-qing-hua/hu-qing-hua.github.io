---
title: "记录一直忽略的工具之类"
date: 2025-04-17T02:01:58+05:30
description: "the missing semester of cs的笔记"
tags: [Note]
---
### 第一章
1.  terminal是负责处理输入输出的窗口，也负责处理窗口显示的字体颜色等。
>(starship,terminal)类似于(网页的js,浏览器引擎)（starship使用标准的ECMA-48控制序列（所有现代终端都支持），就像所有网页都可以在一个浏览器上跑一样
2. shell 负责调用各种命令(eg:echo\cat......),但输入重定向和输出重定向之类的是shell负责实现的
3. 命令是由系统能力集里来的，就像下图我们寻找它的程序路径
![alt text](/assets//04171.png)
4. 举例子
![alt text1](/assets/04172.png)

### 第二章
2.work2:
```sh
#! /usr/bin/fish

function marco
pwd > /tmp/missing/record.txt
    echo save the path done
end

function polo
if test -f /tmp/missing/record.txt
        if cd (cat /tmp/missing/record.txt)
        echo cd successed 
        else
        echo cd failed
        end
    else
        echo can not find record.txt.
    end
end
```
3.work3:
循环调用找bug的脚本
```sh
#!/usr/bin/fish
set n 0

while true
    ./base.sh >> ./stdout.txt 2>> ./stderr.txt
    if test $status -ne 0
        set n (math $n + 1)
        echo stdout
        cat stdout.txt
        echo stderr
        cat stderr.txt
        echo run number: $n
        exit 0
    else
        set n (math $n + 1)
        echo continue $n
    end
end
```
被调用的脚本
```sh
#! /usr/bin/fish

set n (math (random) % 100)

if test $n -eq 42
        echo error
        echo error:magic number >&2
        exit 1
else
        echo success
end
```
4. shell里面The true program will always have a 0 return code and the false command will always have a 1 return code.
0:成功；1：失败；
 
5. -exec : 直接把找到的文件替换路径
```
>find . -name "*.txt" -exec rm {} \;
> # 实际执行过程类似：
># rm ./file1.txt
># rm "./file with space.txt"
># rm ./file2.txt ...

xargs:接收的是find输出的文本流
>find . -name "*.txt" | xargs rm
># 实际执行过程类似：
># rm ./file1.txt ./file2.txt "file" "with" "space.txt" # 错误分割./file with space.txt
这种情况要 find -print0 | xargs -0
```

