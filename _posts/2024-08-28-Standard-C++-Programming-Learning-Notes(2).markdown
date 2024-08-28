---
layout: post
title:  "Standard C++ Programming Learning Notes(2)"
date:   2024-08-23
categories: blog

---

## Week5 2024/8/23👌-2024/8/27👍
### 0️⃣ Review: Const and Const Correctness
- Use const parameters and variables wherever you can in application code
- Every member function of a class that doesn’t change its member variables should
be marked const
- auto will drop all const and &, so be sure to specify
  - When you use auto to deduce the type of a variable, the resulting type will be a copy by default, which means it will not include const or reference (&) qualifiers from the expression being assigned.
  ```cpp
  const int x=42;
  auto y=x;//y is int,not const int;
  const auto y=x;//y is const int
  auto& y = x; // y is int& (a reference to x)
  const auto& y = x; // y is const int& (a reference to a const int)
  ```
- Make iterators and const_iterators for all your classes!
  - const iterator = cannot increment the iterator, can dereference and change underlying value
  - const_iterator = can increment the iterator, cannot dereference and change underlying value
  - const const_iterator = cannot increment iterator, cannot change underlying value
  - https://stackoverflow.com/questions/70028107/in-c-is-const-iterator-the-same-as-const-iterator

### 1️⃣ Template Functions
**Why do we want generic C++?**
<br>C++ is strongly typed, but generic C++ lets you parametrize data types!
- Ex. variable return type or input in a class (template classes)
<br>Can we parametrize even more?<br>
Can we write a function that works on **any data type**?<br>

**Why not!**<br>
**<font color=orange>Template functions</font>**:<br>
Functions whose functionality can be adapted to more than one type or class without repeating the entire code for each type.<br>

**Aside: Constraints and Concepts**
<br>As of C++20, we can limit the acceptable types in:
- template classes
- template functions
- non-template member functions of a template class

These limits or requirements on are called **constraints**.
A named set of constraints is a **concept**. 
```cpp
template<typename T>
concept Addable=requires(T a,Tb){
    a+b;
};

template<typename T>requires Addable<T>
T add(T a,T b){return a+b;}

template<Addable T>
T add(T a,T b){return a+b;}
```

**default Types**
```cpp
template <typename Type=int>
Type myMin(Type a,Type b){
    return a<b?a:b;
}
```

**Calling template functions**
```cpp
template <typename Type>
Type myMin(Type a,Type b){
    return a<b?a:b;
}
cout<<myMin<int>(3,4)<<endl;
```
We can also implicitly leave it for the compiler to deduce! 

```cpp
template <typename T,typename U>
auto myMin(T a,U b){
    return a<b?a:b;
}
cout<<myMin(3.5,4)<<endl;
```

**Behind the Instantiation Scenes**
<br>Remember: like in template classes,**template functions are not compiled until used!**
- For each instantiation with different parameters, the compiler generates a new specific version of your template
- After compilation, it will look like you wrote each version yourself<br>

**Wait a minute…**<br>
The code doesn’t exist until you instantiate it, which runs quicker.<br>
Can we take advantage of this behavior? Yes!

### 2️⃣ Template metaprogramming
**Templates can be used for efficiency!**<br>
Normally, code runs during **runtime**.<br>
With template metaprogramming, code runs **once** during **compile time**!
```cpp
template<unsigned n>//模板结构体 Factorial，它接受一个无符号整数 n 作为模板参数
struct Factorial{
    enum{value=n*Factorial<n-1>::value};
};

template<>//template class "specialization" 模板特化
struct Factorial<0>{
    enum{value=1};
};
std::cout<<Factorial<10>::value<<endl;
//prints 3628800(就是10！),but run during compile time!
```

**Aside: constexpr**
<br>There are other ways in C++ to make code run during compile time.
The constexpr keyword specifies a constant expression.
- Constant expressions must be immediately initialized and will run at compile time!
- Passed arguments to constant expressions should be const/constant expressions as well.
Variables can also be declared as constexpr !<br>

**constexpr** is an institutionalization of template metaprogramming and is often more readable!
```cpp
#include <iostream>
constexpr long long fib(int n) { //function declared as constexpr 这样这个函数会在编译的时候求值
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

int main() {
    const long long bigval = fib(20); 
    std::cout << bigval << std::endl; 
    return 0;
}
```
**Why?**<br>
Overall, can increase performance for these pieces!
- Compiled code ends up being smaller
- Something runs once during compiling and can be used as many times as you like during runtime
TMP was an accident; it was discovered, not invented!

**Applications of TMP**<br>
TMP isn’t used that much, but it has some interesting implications:
- Optimizing matrices/trees/other mathematical structure operations
- Policy-based design
- Game graphics

### 3️⃣ Introduction to Algorithms
**Solving problems with generics**
<br>What if we wanted to count all the occurrences of a character in a string?<br>
Or a number in a vector?<br>
Or a word in a stream?<br>
**These are all the same problem!**<br>

**Summary**
- Template functions allow you to parametrize the type of a function to be anything without changing
functionality
- Generic programming can solve a complicated conceptual problem for any specifics – powerful and flexible!
- Template code is instantiated at compile time; template metaprogramming takes advantage of this to run code at compile time<br>

### 4️⃣ Functions and Lambdas
***How can we make template functions even more general?***<br>
Let’s review that count_occurrences function!
This is a successfully templated function!
```cpp
template <typename InputIt, typename DataType>
int count_occurrences(InputIt begin, InputIt end, DataType target)
{
    int count = 0;
    for (auto iter = begin; iter != end; ++iter)
    {
        if (*iter == target)
        {
            count++;
        }
    }
    return count;
}

std::string str = "Tchaikovsky";
std::cout << "Occurrences of the letter k in Tchaikovsky: " << count_occurrences(str.begin(), str.end(), 'k') << std::endl;
```
This code will work for any containers with any types, for a single specific target.<br>
Will this work for a more general category of targets than one specific value?<br>
What if we wanted to find all the vowels(元音) in “Tchaikovsky”?<br>
**Predicate Functions**
Any function that returns a boolean value is a predicate!
- isVowel() is an example of a predicate, but there are tons of others we might want!
- A predicate can have any amount of parameters…

```cpp
template <typename InputIt, typename UniPred>
int count_occurrences(InputIt begin, InputIt end, UniPred pred)
{
    int count = 0;
    for (auto iter = begin; iter != end; ++iter)
    {
        if (pred(*iter))
        {
            count++;
        }
    }
    return count;
}

bool isVowel(char c)
{
    std::string vowels = "aeiou";
    return vowels.find(c) != std::string::npos;
}

std::string str = "Tchaikovsky";
std::cout << "Occurrences of the letter k in Tchaikovsky: " << count_occurrences(str.begin(), str.end(), isVowel) << std::endl;
```

<br>What type is UniPred???
inconceivable<br>

**Function Pointers**
UniPred is what’s called a function pointer!
- Function pointers can be treated just like other pointers
- They can be passed around like variables as parameters or in template functions!
- They can be called like functions!<br>

现在的example的问题：Poor Generalization
Unary（一元） predicates are pretty limited and don’t generalize well.
我们知道还有二元的predicate fucntion.
Ideally, we’d like something like this!

```cpp
//从一元的
bool isMorethan3(int num){
    return num>3;
}
//到
bool isMorethan(int num,int limit){
    return num>limit;
}
```

<br>回到这个例子，Can we use binary predicates?
If we could, it would be nice to use a binary predicate to handle this!

```cpp
template <typename InputIt, typename BinPred>
int count_occurrences(InputIt begin, InputIt end, BinPred pred)
{
    int count = 0;
    for (auto iter = begin; iter != end; ++iter)
    {
        if (pred(*iter,???))
        {
            count++;
        }
    }
}
```

<br>We can’t pass this in from the predicate!  调用这里不好写count_occurrences(str.begin(), str.end(), isVowel)
<br>
We want our function to know more information about our predicate.<br>
However, we can’t pass in more than one parameter.<br>
How can we pass along information without needing another parameter?
<br>

**Let's use lambdas**<br>
Lambdas are inline, **anonymous** functions that can know about variables declared in their same scope!<br>
auto var = <font color=orange>[capture-clause]</font> <font color=blue>(auto param)</font>  -> bool
{
    ...<font color=green>Function body goes here!</font>
}
<font color=orange>[capture-clause]</font>:Outside parameters go here<br>
<font color=blue>(auto param)</font>:Specifies that Type is generic
<br><br>
eg:

```cpp
int limit=5;
auto isMoreThan=[limit](int n){return n>limit;};
isMoreThan(6);
```
<br>Capture Clauses
You can capture any outside variable, both by reference and by value.<br>
- Use just the = symbol to capture everything by value, and just the & symbol to capture everything by reference.<br>
https://stackoverflow.com/questions/21105169/is-there-any-difference-betwen-and-in-lambda-functions<br>
一个存储值的副本，一个存引用<br>

We’ve solved our problem!
```cpp
#include <iostream>
#include <string>
template <typename InputIt, typename UniPred>
int count_occurrences(InputIt begin, InputIt end, UniPred pred)
{
    int count = 0;
    for (auto iter = begin; iter != end; ++iter)
    {
        if (pred(*iter))
        {
            count++;
        }
    }
    return count;
}

int main()
{
    std::string vowels = "aeiou";
    auto isVowel = [vowels](char c)
    {
        return vowels.find(c) != std::string::npos;
    };
    std::string str = "Tchaikovsky";
    std::cout << "Occurrences of the letter k in Tchaikovsky: " << count_occurrences(str.begin(), str.end(), isVowel) << std::endl;
}
```

**Using Lambdas**<br>
Lambdas are pretty computationally cheap and a great tool!<br>
- Use a lambda when you need a short function or to access local variables in your function.
- If you need more logic or overloading, use function pointers.<br>

**Aside: What the Functor?**<br>
A functor is any class that provides an implementation of operator().<br>
- They can create closures of “customized” functions! (Closure: a single instantiation of a functor object)
- Lambdas are just a reskin of functors!<br>

**Tying it all together**<br>
So far, we’ve talked about lambdas, functors, and function pointers.<br>
The STL has an overarching, standard function object!<br>
std::function<return_type(param_types)> func;<br>
Everything (lambdas, functors, function pointers) can be cast to <u>a standard function</u>(Bigger and slightly more expensive than a function pointer or lambda!)!<br>

**Aside: Virtual Functions**<br>
Be careful using function pointers with classes, especially if you have a subclass of another class!
```cpp
#include <iostream>
class Animal
{
public:
    // constructors and other methods go here!
    void speak()
    {
        std::cout << "I'm an animal!" << std::endl;
    } // private information and the rest of the class goes here!
};

class Dog : public Animal // this syntax tells us we're a subclass of Animal!
{
    // constructors and private information here!
public:
    void speak()
    {
        std::cout << "I'm a dog!" << std::endl;
    } // private information and the rest of the class goes here!
};

void func(Animal *animal)
{
    animal->speak();
}

int main()
{
    Animal *myAnimal = new Animal;
    Dog *myDog = new Dog;
    func(myAnimal);//I'm an animal!
    func(myDog);//I'm an animal!
}
```
problem:*The function expects an Animal, so it will try to use the Animal speak function! It doesn’t know it’s been overridden!*

Ⓜ️If you have a function that can take in a pointer to the superclass, it won’t know to use the subclass’s function!<br>
Ⓜ️The same issue happens if we create a superclass pointer to an existing subclass object.<br>
Ⓜ️To fix this, we can mark the overridden function as **virtual** in the header!<br>
Ⓜ️Virtual functions are functions in the superclass we expect to be overridden later on.<br>

改正：
```cpp
#include <iostream>
class Animal
{
public:
    // constructors and other methods go here!
    virtual void speak()✨
    {
        std::cout << "I'm an animal!" << std::endl;
    } // private information and the rest of the class goes here!
};

class Dog : public Animal // this syntax tells us we're a subclass of Animal!
{
    // constructors and private information here!
public:
    void speak()
    {
        std::cout << "I'm a dog!" << std::endl;
    } // private information and the rest of the class goes here!
};

void func(Animal *animal)
{
    animal->speak();
}

int main()
{
    Animal *myAnimal = new Animal;
    Dog *myDog = new Dog;
    func(myAnimal); // I'm an animal!
    func(myDog);    // I'm a dog!✨
}
```

### 5️⃣ Algorithms
## Week6 2024/8/27🤨-2024/8/28😫
### 1️⃣ Recap:classes
**Objects and Classes**
- Objects are instances of classes
- Objects encapsulate data related to a single entity
  - Define complex behavior to work with or process that data:
  Student.printEnrollmentRecord()
- Objects store private state through instance variables
  - Student::name
- Expose private state to other through public instance methods
  - Student::getName()
- Allow us to expose state in a way we can control
<br>

**We almost have everything we need!**<br>
Classes let you define new objects with new behavior!
- We know how to parametrize classes and functions using templates!
- But...
- Remember maps and sets?
- And structs in streams?
- And functors?
We’re missing something important!

### 2️⃣ Operators and Operator Overloading
How can we repurpose common operators to write descriptive and functional code?

How do operators work with classes?
- Just like declaring functions in a class, we can declare operator functionality!
- When we use that operator with our new object, it performs a custom function or operation!
- Just like in function overloading, if we give it the same name, it will override the operator’s behavior!<br>

What <font color=orange><u>can’t</u></font> be overloaded?
- Scope Resolution 🈶::
- Ternary(三元运算符) 🈶?
- Member Access 🈶.
- Pointer-to-member access 🈶.*
- Object size, type, and casting 🈶sizeof(),typeid(),cast()

<br>We can overload operators in two ways:<br>
<u>Member functions</u>
- Declare your overloaded operator within the scope of your class!
- Allows you to use member variables of this->
<u>Non-member functions</u>
- Declare the overloaded operator outside of any classes (main.cpp?)
- Define both left and right hand objects as parameters

<font color=orange>What if we don’t know what will be on the left-hand side?</font>
**Non-member overloading**<br>
Non-member overloading is preferred by the STL!
- It allows the LHS to be a non-class type (ex. comparing double to a Fraction)
- Allows us to overload operators with classes we don’t own! (ex. vector to a StudentList)
  - bool operator< (const Student& lhs, const Student& rhs);

**What about member variables?**<br>
With member function overloading, we have access to this-> and its private variables.<br>
Can we still access these with non-member operator overloading?
**Everything is better with friends!**<br>
The friend keyword allows non-member functions or classes to access private information in another class!
- To use, declare the name of the function or class as a friend within the target class’s header!
- If it’s a class, you must say friend class [name];
```cpp
//eg:重载<<
#include <iostream>
//法一：友元函数
class Time {
private:
    int hours;
    int minutes;
    int seconds;

public:
    Time(int h, int m, int s) : hours(h), minutes(m), seconds(s) {}

    // Declaring operator<< as a friend function
    friend std::ostream& operator<<(std::ostream& out, const Time& time);
};

std::ostream& operator<<(std::ostream& out, const Time& time) {
    out << time.hours << ":" << time.minutes << ":" << time.seconds;
    return out;
}

int main() {
    Time currentTime(10, 30, 45);
    std::cout << currentTime << std::endl; // Output: 10:30:45
    return 0;
}
//法二：getter函数
#include <iostream>

class Time {
private:
    int hours;
    int minutes;
    int seconds;

public:
    Time(int h, int m, int s) : hours(h), minutes(m), seconds(s) {}

    int getHours() const { return hours; }
    int getMinutes() const { return minutes; }
    int getSeconds() const { return seconds; }
};

std::ostream& operator<<(std::ostream& out, const Time& time) {
    out << time.getHours() << ":" << time.getMinutes() << ":" << time.getSeconds();
    return out;
}

int main() {
    Time currentTime(10, 30, 45);
    std::cout << currentTime << std::endl; // Output: 10:30:45
    return 0;
}

```
**Be careful with non-member overloading!**<br>
Certain operators, like <font color=orange>new and delete</font>, don’t require a specific type.
- Overloading this outside of a class is called global overloading and will affect everything!
void* operator new(size_t size);

### 3️⃣ Special Member Function Overview
There are six special member functions!Special Member Functions (SMFs)<br>
These functions are generated only when they're called (and before any are explicitly defined by you):
- Default constructor
- Destructor
- Copy constructor
- Copy assignment operator(拷贝 赋值 运算符 ‘assignment有赋值/任务/分配 的意思’)
- Move constructor
- Move assignment operator
```cpp
class Widget{
    public:
    Widget();//Takes no parameters and creates a new object
    Widget(const Widget&w);//Creates a new object as a member-wise copy of another
    Widget& operator=(const Widget&w);//Assigns an already existing object to another
    ~Widget();
    Widget(Widget&& rhs);
    Widget& operator=(Widget&& rhs);
}
```
### 4️⃣ Copy and copy assignment
**Review: Initializer Lists**<br>
When we create a constructor, we need to initialize all of our member variables.
- However, initializing them to be the default value and then reassigning is inefficient!
```cpp
template<typename T>
vector<T>::vector<T>(){
    _size=0;//这里做的其实是先把_size默认构造出来然后再赋值
    _capacity=kInitialSize;
    _elems=new T[kInitialSize];
}
```
Instead, we can use initializer lists to declare and initialize them with the desired values all at once!
```cpp
template<typename T>
vector<T>::vector<T>():
_size(0),_capacity(kInitialSize),//这是在构造函数体前完成初始化，不需要多余构造赋值
_elems(new T[kInitialSize]){}
```
- It’s quicker and more efficient to directly construct member variables with intended values
- What if the variable is a non-assignable（不可赋值） type?
- Can be used for any constructor, even non-default ones with parameters!

**Why override special member functions?**<br>
Sometimes, the default special member functions aren’t sufficient（足够）!
- By default, the copy constructor will create copies of each member variable.
- This is member-wise copying!（成员级复制，也就是浅拷贝）
- But is this always good enough?

**What about pointers?**<br>
If your variable is a pointer, a member-wise copy will point to the same allocated data, not a fresh copy!
```cpp
//eg:如果两个对象都尝试释放这个内存，可能会出问题
class Student{
public:
    int* data;
    Student(int size):data(new int[size]){}
    Student(const Student& other){
        data=other.data;//member-wise copying
    }
};

```

Copying isn’t always simple!<br>
Many times, you will want to create a copy that does more than just copies the member variables.
- Deep copy: an object that is a complete, independent copy of the original

In these cases, you’d want to override the default special member functions with your own implementation!<br>
Declare them in the header and write their implementation in the .cpp, like any function!

### 5️⃣ Default and delete
What would you do to prevent copies?<br>
Let’s say you have a class that handles all of your passwords:
```cpp
class PasswordManager{
public :
PasswordManager();
~PasswordManager();
//other methods
PasswordManager(const PasswordManager&rhs);
PasswordManager& operator=(const PasswordManager& rhs);
private:
// other important members
}
```
**We can delete special member functions!**
Setting a special member function to **delete** removes its functionality!
```cpp
class PasswordManager{
public :
PasswordManager();
~PasswordManager();
//other methods
PasswordManager(const PasswordManager&rhs)=delete;
PasswordManager& operator=(const PasswordManager& rhs)=delete;
private:
// other important members
}
```
Now copying isn't a possible operation!
<br>**Uses**<br>
We can selectively allow functionality of special member functions!
- This has lots of uses – what if we only want one copy of an instance to be allowed?
- This is how classes like <font color=orange>std::unique_ptr</font> work!
<u>该类满足 MoveConstructible 和 MoveAssignable 的要求，但不满CopyConstructible 和 CopyAssiqnable 的要求。</u>

**=default?**<br>
We can also keep the default copy constructor if we declare other constructors!

```cpp
class PasswordManager{
public :
PasswordManager()=default;
PasswordManager(const PasswordManager& pm)=default;
~PasswordManager();
//other methods
PasswordManager(const PasswordManager&rhs)=delete;
PasswordManager& operator=(const PasswordManager& rhs)=delete;
private:
// other important members
}
```
Declaring any user-defined constructor will make the default disappear without this!

**The Rule of 0**<br>
If the default SMFs work, don’t define your own! We should only define new ones when the default ones generated by the compiler won't work.
- This usually happens when we work with dynamically allocated memory, like pointers to things on the heap.

**The Rule of 3**<br>
If you have to define a destructor, copy constructor, or copy assignment operator, you should define all three!
- Needing one signifies you’re handling certain resources manually.
- We then should handle the creation, assignment, use, and destruction of those resources ourselves!

**Recap**<br>
The four special member functions discussed so far:
- Default Constructor
  - Object created with no parameters, no member variables instantiated
- Copy Constructor
  - Object created as a copy of existing object (member variable-wise)
- Copy Assignment Operator
  - Existing object replaced as a copy of another existing object.
- Destructor
  - Object destroyed when it is out of scope.

### 6️⃣ Move and move assignment
**Is copying enough?**<br>
We’ve learned about the default constructor, destructor, and the copy constructor and assignment operator.
- We can create an object, get rid of it, and copy its values to another object!
- Is this ever insufficient?

**This can be wasteful!**<br>
Let's say we had to copy our current StringTable into another, whose reference is given to us, and we have no use for our StringTable afterwards.
```cpp
class StringTable{
    public:
    StringTable(){}
    StringTable(const StringTable& st){}
    ...
    private:
    std::map<int,std::string>values;
}
```
<font color=orange>The copy constructor will copy every value in the values map one by one! Very slowly!</font>

```cpp
class Widget{
    public:
    Widget();
    Widget(const Widget&w);
    Widget& operator=(const Widget&w);
    ~Widget();
    Widget(Widget&& rhs);//let's talk about it now👌
    Widget& operator=(Widget&& rhs);//let's talk about it now👌
}
```

**Move operations**
- Move constructors and move assignment operators will perform "memberwise moves."
- Defining a move assignment operator prevents generation of a move copy constructor, and vice versa.
  - If the move assignment operator needs to be re-implemented, there'd likely be a problem with the move constructor!

**Caveats**<br>
Move constructors and operators are only generated if:
● No copy operations are declared
● No move operations are declared
● No destructor is declared

Declaring any of these will get rid of the default C++ generated operations.

If we want to explicitly support move operations, we can set the operators to default:

```cpp
Widget(Widget&&)=default;
Widget& operator=(Widget&&)=default;//support moving
Widget(const Widget&)=default;
Widget& operator=(const Widget&)=default;//support copying
```










