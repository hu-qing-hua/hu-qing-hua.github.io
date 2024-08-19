---
layout: post
title:  "Standard C++ Programming Learning Notes"
date:   2024-08-19 12:00:00 +0800
categories: jekyll update
---

# 📕Standard C++ Programming Learning Notes

## Week1 2024/8/1😶‍🌫️-2024/8/5🤗

### 1️⃣STL:standard template library

### 2️⃣**Compiled vs Interpreted:**

**when is source code translated❔**

<u>Dynamically typed,interpreted</u>

-Types are checked on the fly,during exection,line by line

-Example:Python

<u>Statically typed,compiled</u>

-Types before program runs during compliation

-Example:C++

衍生问题：<mark>how does the pre-processing,complication,assembly and linker work in C++？</mark>

很好的回答1：[Compile &amp; Execute | Codecademy](https://www.codecademy.com/article/cpp-compile-execute-locally)

很好的回答2:[c++ - How does the compilation/linking process work? - Stack Overflow](https://stackoverflow.com/questions/6264249/how-does-the-compilation-linking-process-work)

(最多赞前两位)

很像课本最详细的回答3：

C++的构建流程可以分为四个主要阶段：预处理、编译、汇编和链接。下面是每个阶段的详细说明：

1. 预处理 (Preprocessing)

在这个阶段，C++源代码文件（通常以 `.cpp` 扩展名结尾）会被预处理器处理。主要任务包括：

- **文件包含**：用 `#include` 指令包含其他文件的内容（比如头文件）。
- **宏替换**：用 `#define` 指令定义的宏会被展开。
- **条件编译**：用 `#ifdef`、`#ifndef`、`#if` 等指令控制代码的编译条件。
- **删除注释**：删除源代码中的注释。

预处理器的输出是一个处理过的源代码文件，通常没有 `.cpp` 扩展名，而是带有 `.i` 扩展名的中间文件，虽然这个文件在实际开发中通常不会显示出来。

2. 编译 (Compilation)

编译阶段将预处理后的源代码文件转换为汇编语言代码。编译器的主要任务包括：

- **语法分析**：检查代码是否符合C++语言的语法规则。
- **语义分析**：检查代码的语义，确保代码逻辑正确。
- **优化**：对代码进行各种优化以提高执行效率。
- **生成中间代码**：将源代码转换为中间表示（IR），如抽象语法树（AST）。

编译器生成的输出是目标文件（通常以 `.obj` 或 `.o` 扩展名结尾），它包含机器代码，但仍然需要进一步处理。

3. 汇编 (Assembly)

汇编阶段将编译器生成的汇编语言代码转换为机器代码。汇编器（Assembler）将汇编语言指令翻译成二进制格式的机器代码，并生成目标文件（`.obj` 或 `.o` 文件）。

4. 链接 (Linking)

链接阶段将一个或多个目标文件（`.obj` 或 `.o` 文件）和库文件（如标准库、第三方库）组合成一个可执行文件。链接器（Linker）的主要任务包括：

- **符号解析**：将目标文件中的函数和变量引用解析为实际的内存地址。
- **重定位**：调整目标文件中的地址引用，使它们指向正确的内存位置。
- **合并段**：将多个目标文件的代码段和数据段合并在一起。
- **生成可执行文件**：生成最终的可执行文件（通常是 `.exe` 文件或没有扩展名的文件，取决于操作系统）。

### 3️⃣the problem with types so far

🤔first,**it can be a pain to know what the type of a variable is**.

Aside:<u>the auto keyword</u>

auto:a keyword used in lieu of type when declaring a varible that tells the compiler to deduce the type.

[this is not the same as no having a type!]

[the compiler is able to determine the type itself without being explicitly told.]

🤔second,**any given fucntion can only have exactly one return type**

🤔third,**C++ primitives (and even the types in the STL) can be limited**

➡️what is a struct :A struct is a a group of named variables, each with their own type, that allows programmers to bundle different types together!

```c
struct Student{
    string name;//these are called fields
    string state;
    int age;
};//end the structure with a semicolon
Student s;
s.name="dolly";
s.state="AR";
s.age=21;
```

➡️the STL has its own structs!

<u>std::pair</u> 

```c
//like this
struct Pair{

fill_in_type first;

fill_in_type second;

};
```

*More useful than I thought.-> it can return sucess and result*

```cpp
std::pair<bool, Student> lookupStudent(string name) {
 Student blank;
 if (notFound(name)) return std::make_pair(false, blank);
 Student result = getStudentWithName(name);
 return std::make_pair(true, result);//avoid specifying the type
}
auto output = lookupStudent(“Julie”);//auto makes this neater
```

## Week2 2024/8/5🦄-2024/8/8🖼️

### 1️⃣what is Initialization

---->Provides initial values at the time of construction.

**How**❔

① **<u>direct initialization</u>**

-> C++ doesn't care (eg: int s=12.5;). it doesn't type check with direct initialization

----><mark>narrowing conversion</mark>

② **<u>uniform initialization</u>**(a feature in <mark>C++ 11</mark>)

❗notice: the curly braces‼️ (eg:int s=<mark>{</mark>12.5<mark>}</mark>;)

-->with uniform initialization C++ does care about types!

🎉Uniform initialization is awesome because:

- It’s <mark>safe</mark>! It doesn’t allow for narrowing conversions—which can lead to unexpected behaviour (or critical system failures :o)

- It’s <mark>ubiquitous</mark> it works for all types like vectors, maps, and custom classes, among other things!
  
  ```cpp
  //eg:Map
  std::map<std::string,int>ages{
    {"Alice",25}, 
    {"Bob",30},
    {"Charlie",35} 
  };
  std::cout<<"Alice "<<ages["Alice"]<<std::endl;
  std::cout<<"Bob "<<ages.at("Bob")<<std::endl;
  
  //eg:vector
  std::vector<int>numbers{1,2,3,4,5};
  ```
  
  ```cpp
  //eg:struct
  //before
  Student s;
  s.name="dolly";
  s.state="AR";
  s.age=21;
  //after
  Student s{"dolly","AR",21};😘
  ```

③ <u><strong>structured binding</strong></u>(a feature in <mark>C++ 17</mark>)

1.A useful way to initialize some variables from data structures with fixed sizes at compile time
2.Ability to access multiple values returned by a function

```cpp
//eg:pair
#include <iostream>
#include <utility>
#include <string>

std::pair<int, std::string> getUserInfo() {
  return {42, "Alice"};
}

int main() {
  // C++17 之前的写法
  auto userInfo = getUserInfo();
  int id = userInfo.first;
  std::string name = userInfo.second;

  // C++17 使用结构化绑定
  auto [id, name] = getUserInfo();

  std::cout << "ID: " << id << ", Name: " << name << std::endl;
  return 0;
}

//eg:tuple
#include <iostream>
#include <tuple>
#include <string>

std::tuple<int, std::string, double> getDetails() {
  return {7, "Beta", 3.14};
}

int main() {
  // C++17 之前的写法
  std::tuple<int, std::string, double> details = getDetails();
  int number = std::get<0>(details);
  std::string text = std::get<1>(details);
  double value = std::get<2>(details);

  // C++17 使用结构化绑定
  auto [number, text, value] = getDetails();

  std::cout << "Number: " << number << ", Text: " << text << ", Value: " << value << std::endl;
  return 0;
}

//eg:自定义的struct
#include <iostream>

struct Point {
  int x;
  int y;
};

Point getPoint() {
  return {10, 20};
}

int main() {
  // C++17 使用结构化绑定
  auto [x, y] = getPoint();

  std::cout << "X: " << x << ", Y: " << y << std::endl;
  return 0;
}
```

### 2️⃣<mark>References</mark>

what❓

Declare a name variable as a reference.

a reference is an alias to an already-existing thing.

how❓

use an ampersand(&)

```cpp
int num=5;
int& ref=num;//ref is a variable of type int&, that is an alias to num


//pass by reference
void squareN(int& n);
```

A reference refers to <mark>the same memory</mark> as its associated variable!

Passing in a variable by ***reference*** into a function just means 

<u>“Hey take in the actual piece of memory, don’t make a copy!”</u>

Passing in a variable by ***value*** into a function just means 

<u>“Hey make a copy, don’t take in the actual variable!”</u>

an edge case______a calssic reference-copy bug_

```cpp
#include <iostream>
#include <math.h>
#include <vector>

void shift(std::vector<std::pair<int, int>>& nums) {//虽然是nums的reference
//for (auto [num1, num2] : nums) {//✖️没有修改num1和num2
for (auto& [num1,num2]:  nums){//✔️
        num1++;
        num2++;
    }
}

int main() {
    std::vector<std::pair<int, int>> nums = { {1, 1}, {2, 3} };
    shift(nums);
    for (const auto& p : nums) {// 如果用auto p的话，又是复制了一个副本，没必要
//使用const 保证变量不会被修改，只读
        std::cout << "(" << p.first << ", " << p.second << ") ";
    }
}
```

### 3️⃣L-values vs R-values

An <font color=blue>**l-value**</font> can be to the left <u>***or***</u> the right of an equal sign!

eg: ✅int y=x; ✅x=344;

An <font color=red>**r-value**</font> can be ⭐<u>***ONLY***</u>⭐ to the right of an equal sign!

eg:✅int y=21;  ❌21=x;

```cpp
#include<iostream>
#include<stdio.h>
#include<cmath>

int squareN(int&num){  //is int&num an l-value? ---->L
    return std::pow(num,2);
}

int main(){
    int lValue=2;
    auto four=squareN(lValue);
    auto fourAgain=squareN(2);//❌会报错
    std::cout<<four<<std::endl;
    return 0;
}
```

It turns out that num is an l-value! But Why?

1. Remember what we said about **r-values are temporary**. Notice that num is being passed in by reference!
2. We <u>***cannot***</u> pass in an r-value by reference because they’re temporary!

### 4️⃣<u><mark>const</mark></u>

what ❔

A qualifier(限定符) for objects tha declares they cannot be modified.

```cpp
std::vector<int>vec{1,2,3};
const std::vector<int>const_vec{1,2,3};//a const vector
std::vector<int>&ref_vec{vec};//a reference to 'vec'
const std::vector<int>& const_ref{vec};//a const reference

//Bad
//❗you can't declare a non-const reference to a const variable
std::vector<int>&bad_ref{const_vec};//❌
//Good
const std::vector<int>&const_ref_vec{const_vec};//✅

vec.push_back(3);//✅
const_vec.push_back(3);//❌ this is const
ref_vec.push_back(3);//✅
const_ref.push_back(3);//❌this is const,compile error
```

what else I need to know:

1. A few popular compilers include **clang** and **g++**

### 5️⃣what are streams?

"Designing and implementing a general <u>**input/output**</u> facility for a programming language is notoriously difficult"-----Bjarne Stroustrup

➡️

"~~Designing and implementing~~ a general <u><strong>input/output</strong></u> facility for ~~a programming language is notoriously difficult~~  C++"-----Bjarne Stroustrup

➡️

a general <u><strong>input/output</strong></u> facility for C++

➡️

a general <u><strong>input/output(IO)</strong></u> <mark>abstraction</mark> for C++

Abstractions often provide a consistent <u>***interface***</u>,

and in the case of <font color=darkoragne>streams</font> the interface is for <u>reading</u> and <u>writing</u> data!

**cerr and clog:**

**cerr**:used to output errors

**clog**:used for non-critical event logging

[Difference between cerr and clog - GeeksforGeeks](https://www.geeksforgeeks.org/difference-between-cerr-and-clog/)

std::cout and the IO library (从上而下，上面的是父类，下面的是子类)

https://en.cppreference.com/w/cpp/io

std::cout is included in <font color=chocolate>**"basic_ostream"** </font>in cpp IO library

<u>how do we go from external source to program?</u>

                                          **Implementation vs Abstraction**

                                              🟨🟨🟨🟨🟨🟨🟨🟨🟨                                                 **?**

❓<--(external source)--> 🟨           stream              🟨<--(type conversion)-->fill_in_type

                                              🟨               **"?"**                 🟨                                            in your 

                                              🟨string representation🟨                                           program

                                              🟨 🟨🟨🟨🟨🟨🟨🟨🟨  

<u>why is this even useful?</u>

A:Streams allow for a <mark>universal</mark> way of <mark>dealing with external data</mark>

<u>what is streams actually are?</u>

A:     <font color=chocolote>**"basic_iostream"**</font> in cpp IO library

Classify different types of streams

**Input streams (I)**
● a way to read data from a source
○ Are inherited from **std::istream**
○ ex. reading in something from the console (std::cin)
○ primary operator: >> (called the <mark>extraction</mark> operator)
**Output streams (O)**
● a way to write data to a destination
○ Are inherited from **std::ostream**
○ ex. writing out something to the console (std::cout)
○ primary operator: << (called the <mark>insertion</mark> operator)

<font color=red>我经常分不清<< 和>>:</font>

---->

- **输出**：`std::cout << "Hello, World!";` 这里 `<<` 将字符串 "Hello, World!" 插入到输出流中。
- **输入**：`std::cin >> number;` 这里 `>>` 从输入流中提取数据并存储到 `number` 变量中。

### 6️⃣stringstreams

**what?**     A:a way to treat strings as streams

**Utility?**    A:stringstreams are useful for use-cases that deal with mixing data types

<font color=darkorange>"basic_stringstream" </font>in cpp IO library

```cpp
#include <iostream>
#include <string>
#include <sstream>

int main() {
    // Partial Bjarne Quote
    std::string initial_quote = "Bjarne Stroustrup C makes it easy to shoot yourself in the foot";

    // Create a stringstream
    std::stringstream ss(initial_quote);
//或者
//std::stringstream ss << initial_quote;

    // Data destinations
    std::string first,last,language,extracted_quote;

    // Extract 
    ss >> first >> last>>language;

    // Output the result
    std::cout << first << " " << last << " said this: " << language << " " << extracted_quote << std::endl;

    return 0;
}
```

"Bjarne Stroustrup C makes it easy to shoot yourself in the foot";

stream begin with B,end with "\n"

<u>we want to extract the quote!</u> 

<u>but</u> The >> operatoronly reads until **the next whitespace**!(提取时空格不算在里面，像first是"Bjarne"，不是"Bjarne ")

🔜**Use getline()!**

*<font color=green>istream</font>& getline(<font color=green>istream</font>& is, <font color=blue>string</font>& str, <font color=red>char</font> delim)*
● **getline() reads an input stream**, is, **up until the** delim **char and stores it in some buffer**, str.
● The delim char is by default ‘\n’. 
● getline() ***<u>consumes</u>*** the delim character!
○ PAY ATTENTION TO THIS :)

```cpp
🔜
std::string language, extracted_quote;
ss >> first >> last >> language;
std::getline(ss, extracted_quote);//makes it easy to shoot yourself in the foot
std::cout << first << “ ” << last << “ said this: ‘” << language << “ “ <<
extracted_quote + “‘“ << std::endl;
```

输出：Bjarne Stroustrup said this: 'C makes it easy to shoot yourself in the foot'

### 7️⃣Output streams

● a way to write data to a destination/external source
○ ex. writing out something to the console (std::cout)
○ use the << operator to <u>***send***</u> to the output stream

🧁Character in output streams are stored in an intermediary(中介) buffer before being flushed to the destination.

🍧std::cout stream is **line-buffered**
🍭contents in buffer not shown on external source until an explicit flush occurs!

🌺可以用 std::cout<<std::flush; 刷新输出流，让缓冲区的数据强制写到输出设备上

double tao = 6.28;
std::cout << tao;                 ------------>

| 6   | .   | 2   | 8   |     |
| --- | --- | --- | --- | --- |

-------Flush------>Console

<mark>std::endl</mark>

std::endl tells the cout stream to end the line!

std::endl <u>***also***</u> tells the stream to <font color=purple>**flush**</font>

eg:

```cpp
int main()
{
for (int i=1; i <= 5; ++i) {
std::cout << i << std::endl;
}
return 0;
}
```

intermediate buffer: '1''\n'     [it is immediately sent to destination]

then,When a stream is flushed the **intermediate buffer is cleared**!

->存‘2’之前，buffer是空的

->没存一个值，buffer都清空一次

-><font color=purple>**flushing**</font> is an expensive operation!

->C++ is (kinda) smart! It knows when to auto flush(它会在buffer满的时候自动刷新，以便可以继续往buffer输数据)

<mark>**A shoutout and clarification**</mark>

> However, upon testing these examples,I observed that '\n' seems to
> flush the buffer in a manner similar to std::cout. Further research
> led me to the CPp Reference std::endl, which states, "In many
> implementations, standard output is line-buffered, and writing '\n'
> causes a flush anyway,unless <mark>std::ios::sync with stdio(false)</mark> was
> executed." This suggests that in many standard outputs, '\n' behaves
> the same as std::cout. Additionally, when I appended cat to my
> program,I noticed that in file output, '\n' does not immediately
> flush the buffer.

> 然而，在测试这些例子时，我发现 '\n' 似乎以类似于 std::cout 的方式刷新缓冲区。进一步的研究让我找到了 CPp Reference std::endl，其中指出：“在许多方面实现中，标准输出是行缓冲的，并且写入 '\n'无论如何都会导致刷新，除非 std::ios::sync with stdio(false) 是已执行。”这表明在许多标准输出中，'\n' 的行为与 std::cout 相同。此外，当我将 cat 添加到我的程序，我注意到在文件输出中，'\n'不会立即刷新缓冲区。

解释：

标准输出流（`std::cout`）在许多实现中是行缓冲的，这意味着写入一个换行符 `'\n'` 通常会导致缓冲区被自动刷新。但是，这种情况有机会被改变

---->调用了 `std::ios::sync_with_stdio(false)` 而改变。

- `std::ios::sync_with_stdio(false)` 用于禁用 C++ 标准流（如 `std::cout`）与 C 标准 I/O 函数（如 `printf`, `scanf`）之间的同步。
- 当禁用同步后，C++ 标准流和 C 标准 I/O 函数之间不再保证输出顺序的一致性。更重要的是，禁用同步可能会影响缓冲行为。

---->调用之后，使用'\n'的话，缓冲不会立马输出去，不会频繁刷新，IO消耗小

只有在显示调用flush或者程序结束或者缓冲满的时候，会刷新缓冲

所以比较好的做法 <mark>**use '\n'!**</mark>

```cpp
int main()
{
std::ios::sync_with_stdio(false)
for (int i=1; i <= 5; ++i) {
std::cout << i << ‘\n’;
}
return 0;
}
```

**<mark>Output File Stream</mark>**

● Output file streams have a type: std::ofstream
● a way to write data to a file!
○ use the << insertion operator to <u>send</u> to the file
○ Here are some you should know:
■ is_open()
■ open()
■ close()
■ fail()

### 8️⃣Input streams

● Input streams have the type std::istream
● a way to read data from an destination/external source
○ use the >> extractor operator to read from the input stream
○ Remember the std::cin is the console input stream

**<u>std::cin</u>**

std::cin is buffered
● Think of it as a place where a user can store some data and then read
from it
● std::cin buffer stops at a whitespace
● Whitespace in C++ includes:
○ “ ” – a literal space
○ <font color=purple>\n</font> character
○ <font color=purple>\t</font> character

```cpp
double pi;

std::cin>>pi;
```

|     |     |     |     |     |
| --- | --- | --- | --- | --- |

⬆️ 刚开始 cin buffer is empty so **prompts for input**! 

| 3   | .   | 1   | 4   | '\n' |     |
| --- | --- | --- | --- | ---- | --- |

                                                                                    ⬆️ 

cin not empty so it reads up to white space and saves it to double pi

它读到空白格之前，停下

如果下面还要有cin操作，必须有一个whitespace

Notice that cin <u>***only***</u> reads until the next whitespace

<font color=red>**<u>question</u>**</font>

```cpp
void cinGetlineBug() {
 double pi;
 double tao;
 std::string name;
 std::cin >> pi;
 std::getline(std::cin, name);
 std::cin >> tao;
 std::cout <<pi<< name << tao<<'\n';
}
```

**1** 为什么当我输入12.3 asd das
12
的时候，输出12.3 asd das12 ，12.3和asd之间有空格呢

🔜因为std::cin>>pi的时候，只读到whitespace（也就是空格）之前，

但是getline默认停止是遇见'\n'，所以它会读把空格读进去。

**2** 为什么输入12.3

asd dasa

的时候，输出12.30

🔜因为输完12.3选择的whitespace是'\n'，std::cin>>pi的时候，读到whitespace'\n'之前，getline开始读就收到'\n'就停止了，所以name='';

然后cin>>tao的时候，发现a不是double类型--->报错 输出0

改正：

std::getline(std::cin, name);

std::getline(std::cin, name);

<u>**that being said**</u>

You actually *<u>shouldn’t</u>* use getline() and std::cin() together because of the difference in how they parse data.
If you really do need to though, it is possible, but not recommended.

<mark>To conclude (Main takeaways):</mark>

1. Streams are a general interface to read and write data in programs
2. Input and output streams on the same source/destination type
   compliment each other!
3. Don’t use getline() and std::cin() together, unless you
   really really have to!

## Week3 2024/8/8🩰-2024/8/9👑

### 1️⃣Defining Containers

<u>Container: An object that allows us to collect other objects together and interact with them in some way.</u>

Containers are ways to collect related data together and work with it logically

<mark>Why containers?</mark>  What is the purpose of container types in programming languages?

<u>Organization</u>:Related data can be packaged together!

<u>Standardization</u>:Common features are expected and implemented.

<u>Abstraction</u>:Complex ideas made easier to utilize by clients.

### 2️⃣Containers in the STL vs Stanford

In choosing a programming language, there’s always a tradeoff between **speed**, **power**, and **safety**.

-->延伸：why is C++ so fast

<mark>Standardization:</mark>

Typically, containers export some standard, basic functionality.
● Allow you to store multiple objects (though all of the same type)
● Allow access to the collection through some (perhaps limited) way
               ○ Maybe allow iteration(迭代) through all of the objects
● May allow editing/deletion

there are two types of containers:

<font color=red>Sequence</font>:

● Containers that can be accessed sequentially
● Anything with an inherent order goes here!

Sequence containers are for when you need to enforce some order on your information!

<font color=blue>Associative</font>
● Containers that don’t necessarily have a sequential order
● More easily searched
● Maps and sets go here!

| container                             | principle                                                       | characteristic                                                                                                                                                           | type of Interator |
| ------------------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------- |
| <font color=red>vector</font>         |                                                                 | At a high level, a vector is an **ordered** collection of elements of **the same type** that can <u>grow and shrink</u> insize.   Internally,vectors implement an array! | Random-Access     |
| stack                                 |                                                                 |                                                                                                                                                                          | No Iterator       |
| queue                                 |                                                                 |                                                                                                                                                                          | No Iterator       |
| <font color=blue>set</font>           |                                                                 | Ordered set require a **comparison operator** to be defined                                                                                                              | Bidirectional     |
| <font color=blue>map</font>           | Maps are implemented with pairs! (`std::pair<const key,value>`) | Ordered maps require a **comparison operator** to be defined                                                                                                             | Bidirectional     |
| <font color=red>array</font>          | is the primitive form of a vector                               | fixed size in a strict sequence                                                                                                                                          |                   |
| <font color=red>deque</font>          | is a double ended queue（底层实现很有意思）                               | 可以做到had an array that stored other arrays           🌺If you need particularly fast inserts in the front, consider an std::deque                                         | Random-Access     |
| <font color=red>list</font>           | is a doubly linked list                                         | can loop through in either direction!                                                                                                                                    | Bidirectional     |
| <font color=blue>unordered set</font> |                                                                 | require a **hash function** to be defined. Unordered containers are **faster**, but can be difficult to get to work with nested containers/collections                   |                   |
| <font color=blue>unordered map</font> |                                                                 | require a **hash function** to be defined                                                                                                                                |                   |
| priority queue                        |                                                                 |                                                                                                                                                                          | No Iterator       |

### 3️⃣Container Adaptors

Container adaptors are “wrappers” to existing containers!
● Wrappers **modify the interface** to sequence containers and change what the client is allowed to do/how they can interact with the container.
● How could we make a wrapper to implement a queue from a deque?

A:[std::queue - cppreference.com](https://en.cppreference.com/w/cpp/container/queue)

stack也是如此

**Why?**
Abstraction again!
● Commonly used data structures made easy for the
client to use
● Can use different backing containers based on use type

<font color=orange>**NEW in C++23: flat_map and flat_set are container adaptors of sequence containers that are faster than the default in most use cases!**</font>

### 4️⃣Interators

<u>All containers are collections of objects…
**So how do we access those objects?**</u>
● What if we want to print out everything in a vector?
● Or loop until we find a certain object in a set?
**How is this done in the STL?**

➡️Containers all implement something called an <mark>iterator</mark> to do this!
● Iterators let you access **all** data in containers programmatically!
● An iterator has a certain **order**; it “knows” what element will come next
         ○ Not necessarily the same each time you iterate!

**In the STL**
All containers implement iterators, but they’re not all the same!
● Each container has its own iterator, which can have different behavior.
● All iterators implement a few shared operations:
○ Initializing---------------------------->  iter = s.begin();
○ Incrementing----------------------->  ++iter;
○ Dereferencing---------------------->  *iter;
○ Comparing--------------------------->  iter != s.end();
○ Copying-------------------------------->  new_iter = iter;

<u><font color=blue>What other behaviors can iterators have</font>?</u>

It depends the type of the iterators.

https://cplusplus.com/reference/iterator/

看“The properties of each iterator category are:‘的图

🔵**Forward** iterators are the minimum level of functionality for standard containers.

               🔹 **Input** iterators can appear on the RHS (right hand side) of an = operator

                `auto elem=*it;`

                🔹**Output** iterators can appear on the LHS (left hand side) of an = operator

                `*elem=value;`

🔵**Bidirectional** iterators can go forward as well as backward!

                🔹`--iter;`

                🔹Still has the same functionality of forward iterators!

🔵**Random-access** iterators allow you to directly access values without visiting all elements sequentially.

                 🔹 iter += 5;
                 🔹Think of vectors; vec[1] or vec[17] or…
                 🔹Be careful not to go out of bounds!

**Categorizing STL iterators**
Vectors and deques have the most powerful iterators!
● Creating your own containers means creating their iterators as well.
● You can access elements in stacks and queues one-by-one, but you have to change the container to do so!
● Iteration with iterators is **const**

**Let’s check out that for loop again!**

`for(auto iter=set.begin();iter!=set.end();++iter){}`

If we want the element and not just a reference to it, we dereference (*iter).

`const auto& elem=*iter`

If we have a map, we can use structured binding to be more efficient while dereferencing!

{% raw %}

```cpp
std::map<int, int> map{{1,6}, {2,8}, {0,3}, {3,9}};
for(auto iter = map.begin(); iter != map.end(); iter++) {
const auto& [key, value] = *iter; // structured binding!
}
```

{% endraw %}

### 5️⃣Pointers

**Introducing pointers**

Iterators are a particular type of pointer!
● Iterators “point” at particular elements in a **container**.
● Pointers can “point” at **any objects** in your code!

**<mark>Dereferencing</mark>**
Pointers are marked by the asterisk (*) next to the type of the object they’re pointing at when they’re declared.
The address of a variable can be accessed by using & before its name, same as when passing by reference!
If you want to access the data stored at a pointer’s address,dereference it using an asterisk again.

```cpp
int val=18;
int* ptr=&val;
std::cout>>*ptr>>std::endl;//18
```

**What if the object has member variables?**
If we need to access a pointer’s object’s member variables, instead of dereferencing (*ptr) and then accessing (.var), there’s a shorthand!

`*ptr.val=ptr->val`

**What’s the difference?**
● Iterators are a type of pointer!
● Iterators have to point to elements in a container, but pointers can point to any object!
○ Why is this? All objects stored inside the big container known as **memory**!
● Can access memory addresses with & and the data at an address/pointer using *

## Week4 2024/8/9🕋-2024/8/9🎁

### 1️⃣Introduction to classes

**Why classes?**

●One of the premises of the entire C++ language was the lack of object-oriented-programming (OOP) in C.
● Classes are user-defined types that allow a user to *<u>**encapsulate**</u>* data and functionality using member variables and member functions

**What is object-oriented-programming?**

● Object-oriented-programming is centered around objects
● Focuses on design and implementation of classes!
● Classes are the **user-defined types** that can be declared as an object!

🎉🎉**Surprise!**

Containers are classes defined in the STL!🥳

**Comparing 'struct' and 'class'**

> <mark>classes</mark> containing a sequence ofobjects of various types, a set of functions for manipulating these objects, and a set of restrictions on the access of these objects and function;
> <mark>structures</mark> which are classes without access restrictions,
> 
> -------Bjarne Stroustrup

All these fields are public,i.e. can be changed by the user Because of this, we can’t
enforce certain behaviors in structs, like avoiding a negative age. 

(例如：s.age=-200;例如struct是透明的痛包，class是不透明的🎒);

**Some other cool class stuff**

**Type aliasing** - allows you to create synonymous identifiers for types

```cpp
class Student {
Private:
/// An example of type aliasing
using String = std::string;💟
String name;
String state;
int age;
public:
/// constructor for our student
Student(String name, String state, int age);
/// method to get name, state, and age, respectively
String getName();
String getState();
int getAge();
}
  return 0;
}
```

### 2️⃣Container adapters容器适配器

🎉🎉Surprise!

All containers in the STL are ⭐classes⭐(重复一遍 🪅)

主要有 stack queue priority_queue三种，

用底层容器实现但是只暴露特定接口函数，不揭露实现细节。

例如：

```cpp
template<
    class T,
    class Container = std::deque<T>
> class queue;
```

### 3️⃣Inheritance

**Why inheritance?**

- **Polymorphism多态性**: Different objects might need to have the same interface 
- **Extensibility**: Inheritance allows you to extend a class by creating a subclass with specific properties

```cpp
class Shape {
public:
virtual double area() const = 0;
//This is a virtual function, meaning that it is instantiated in the base class 
//but overwritten in the subclass. (Polymorphism)
};
class Circle : public Shape {
public:
/// constructor
Circle(double radius): _radius(radius) {};// using list initialization construction
double area() const {
return 3.14 * _radius * _radius;
}
private:
double _radius;
//Another pro of inheritance is the encapsulation of class variables.
};
```

**Subclasses vs Container Adapter**

- These are not to be confused
- Subclasses inherit from base class functionality
- Container adapters provide the interface for several classes and act as a **template parameter.**

### 4️⃣Template classes

<font color=pink>**Template Class**</font>: A class that is parametrized over some number of types; it is comprised of member variables of a general type/types.

<u>We can now allow classes to be general, and not redundant冗余!</u>

<mark>template<typename T></mark>:This is a template declaration and allows us to create template classes

<mark>template<typename T,typename U></mark>:This is a template declaration list which can have various template parameters representing different types.

**The difference:**

```cpp
#include "Container.hh"

template<class T>
Container<T>::Container(T val){🎐
    this->value=val;
}

template<typename T>
T Container<T>::getValue(){🎐
    return value;
}

//另一个
#include "Container.hh"

template<class T>
Container::Container(T val){🎐
    this->value=val;
}

template<typename T>
T Container::getValue(){🎐
    return value;
}
```

💟C++ wants us to specify our template parameters in our namespace because, based on the parameters our class may behave differently!
Note: there is no "one" Container,there is one for an int, bool, char,etc., there is one for an int, bool,char, etc.

💟class and type name are interchangeable in the template declaration list.一样用没区别

💟<font color=red><u>模板类的实现也放在头文件，不要在.cpp文件</u></font>

### 5️⃣Const correctness

```cpp
//.h
class Student {
private:
/// An example of type aliasing
  using String = std::string;
  String name;
  String state;
  int age;
public:
  Student(String name, String state, int age);
  /// Added a ‘setter’ function
  void setName(String name);
  String getName();
  String getState();
  int getAge();
  std::string stringify(const Student& s){
     return s.getName() + " is " + std::to_string(s.getAge()) +" years old." ;
  }//compile error❌
//原因：- By passing in s as const we made a promise to not modify s.
//- The compiler doesn’t know whether or not getName() and getAge() modify s
//- Remember, member functions can access and modify member variables
} 
```

<u><strong>Const interface</strong></u>

**Definition**:
*️⃣Objects that are const can only interact with the const-interface.
The const interface <u>is simply the functions that are const/do not modify the object/instance of the class.</u>

```cpp
//订正后
//.h
class Student {
private:
/// An example of type aliasing
  using String = std::string;
  String name;
  String state;
  int age;
public:
  Student(String name, String state, int age);
  /// Added a ‘setter’ function
  void setName(String name);
  String getName()const;🧜‍♀️
  String getState();
  int getAge()const;🧜‍♀️
  std::string stringify(const Student& s){
     return s.getName() + " is " + std::to_string(s.getAge()) +" years old." ;
  }


//.cpp
#include “Student.h”
#include <string>
std::string Student::getName() const {🧜‍♀️
return this->name;
}
std::string Student::getState() {
return this->state;
}
int Student::getAge() const {🧜‍♀️
return this->age;
}
```

之前搞错的小东西：

```cpp
//.h文件
class IntArray {
private:
 int* _array
 size_t _size
public:
// constructor
 IntArray(size_t size);
 ~IntArray();
 int& at(size_t index);
 int size();
}
//.cpp文件
IntArray::IntArray(size_t size) : _size(size), _array(new int[size]);
IntArray::~IntArray() {
  delete [] _array;
}
/// assumes that index is valid
int& at(size_t index) {
  return _array[index];
}
int size() {
  return this->_size;
}
//main文件
#include “IntArray.h”
#include <iostream>
static void printElement(const IntArray& arr, size_t index) {
std::cout << arr.at(index) << std::endl;
}
int main() {
IntArray arr = IntArray(10);
int& secondVal = arr.at(1);
/// actually changes the value of arr at index ‘1’.
secondVal = 19;
printElement(arr, 1);
return 0;
}
```

`static void printElement(const IntArray& arr, size_t inde`这里调用的是const对象别名，所以使用的at成员函数也要是const成员函数

加一个函数`int& at(size_t index)const {
 return _array[index];
}`

我本来想着的是为什么不是

`const int& at(size_t index)const {
 return _array[index];
}`

只能说返回是不是const，语法上是不限制的

看含义：`const` 成员函数是指在成员函数声明末尾加上 `const` 关键字的函数。`const` 成员函数承诺不修改调用对象的状态。[Const member functions in C++ - GeeksforGeeks](https://www.geeksforgeeks.org/const-member-functions-c/)

**Question：遇到这种问题，我们是可以再写一个相同功能的const函数，but the level of
pain/annoying scales linearly with the length of the function**

🔜<mark>const_cast</mark>!

```cpp
int& findItem(int value) {
for (auto& elem: arr) {
if (elem == value) return elem;
}
throw std::out_of_range(“value not found”)
}
const int& findItem(int value) const {
/// one-liners ftw :)
return const_cast<IntArray&>(*this).findItem(value)
}
```

<u>break this down:</u>

💟The **const_cast** is casting away the const

💟<IntArray&> here is the key this is our target. A non-const reference

💟Here we’re dereferencing **this** so that we can cast it as non-const.

<u>step:</u>

1. Cast so that it is pointing to a non-const object
2. Call the non-const version of the function (this is legal now)
3. Then cast the non-const return from the function call to a const version

## W
