---
layout: post
title:  "CS61b Java and Data Structure Notes"
date:   2024-09-18
categories: blog

---

## Lists 1: References, Recursion, and Lists<br>
There are 8 primitive types in Java: <br>
byte, short, int, long, float, double, boolean, char<br>

Everything else, including arrays, is a reference type.<br>

![1](/images/img9.png "test")

box and pointer概念：<br>
The 64 bit addresses are meaningless to us as humans, so we'll represent:<br>
- All zero addresses with “null”.
- Non-zero addresses as arrows.

This is sometimes called “box and pointer” notation.<br>
![111](/images/img17.png "test17")
java里的地址都是64bits,所以图中的a和b都放在64bits的盒子里.Walrus包含int、double变量，java 就设置了一个32bits的盒子和64bits的盒子，Walrus是96bits<br>

传值示例：<br>

```java
public class PollQuestions {
    public static void main(String[] args) {
        Walrus walrus = new Walrus(3500, 10.5);
        int x = 9;

        doStuff(walrus, x);
        System.out.println(walrus);
        System.out.println(x);
    }

    public static void doStuff(Walrus W, int x) {
        W.weight = W.weight - 100;
        x = x - 5;
    }

    public static class Walrus {
        public int weight;
        public double tuskSize;

        public Walrus(int w, double ts) {
            weight = w;
            tuskSize = ts;
        }

        public String toString() {
            return String.format("weight: %d, tusk size: %.2f", weight, tuskSize);
        }
    }
}

//output:
//weight: 3400, tusk size: 10.50
//9
```

概念：<br>
![2](/images/img10.png "test1")

```java
public class IntList {
    public int first;
    public IntList rest;

    public IntList(int f, IntList r) {
        first = f;
        rest = r;
    }

    /** Return the size of the list using... recursion! */
    public int size() {
        if (rest == null) {
            return 1;
        }
        return 1 + this.rest.size();
    }

     /** Return the size of the list using no recursion! */
   public int iterativeSize() {
      IntList p = this;
      int totalSize = 0;
      while (p != null) {
         totalSize += 1;
         p = p.rest;
      }
      return totalSize;
   }

    /** Return the ith item of this IntList. */
   public int get(int i) {
      if (i == 0) {
         return first;
      }
      return rest.get(i - 1);
   }



    public static void main(String[] args) {
        IntList L = new IntList(15, null);
        L = new IntList(10, L);
        L = new IntList(5, L);
       
        System.out.println(L.size());  // should print out 3
        System.out.println(L.get(1));  // should print out 10
    }

}
```

## SLLists, Nested Classes, Sentinel Nodes<br>
以下代码改进了几个方面<br>
1. 先是IntNode取代IntList，再用SLList比原来的方法更好，舍去初始化写入参数null，看上去更简洁，调用addFirst和getFirst更方便<br>
![3](/images/img11.png "test2")
2. 用了private取代public
3. 
![4](/images/img12.png "test3")
![5](/images/img13.png "test4")
4. 增加的addLast和size功能<br>
To implement a recursive method in a class that is not itself recursive (e.g. SLList):<br>
- Create a private recursive helper method.
- Have the public method call the private recursive helper method.<br>

```java
public class SLList {
    private static class IntNode {
        public int item;
        public IntNode next;

        public IntNode(int i, IntNode n) {
            item = i;
            next = n;
        }
    }

    private IntNode first;

    public SLList(int x) {
        first = new IntNode(x, null);
    }

    public void addFirst(int x) {
        first = new IntNode(x, first);
    }

    public void addLast(int x) {
        IntNode p = first;
        while (p.next != null) {
            p = p.next;
        }
        p.next = new IntNode(x, null);
    }

    private int size(IntNode p) {
        if (p.next == null) {
            return 1;
        }

        return 1 + size(p.next);
    }

    public int size() {
        return size(first);
    }

    public int getFirst() {
        return first.item;
    }

    public static void main(String[] args) {
         SLList L = new SLList(15);
        L.addFirst(10);
        L.addFirst(5);
        L.addLast(6);
        System.out.println(L.getFirst()); // should print 5
        System.out.println(L.size());   //4
    }

}
```

上面使用递归方法计算size,Suppose size takes 2 seconds on a list of size 1,000.<br>
How long will it take on a list of size 1,000,000?<br>
2000s,差不多33分钟了<br>

**Solution**: Maintain a special size variable that caches the size of the list. <br>
Caching: putting aside data to speed up retrieval.<br>
<br>

```java
private int size;

public int size() {
    return size;
}
//然后在add、构造的时候 size+=1;
```

TANSTAAFL: There ain't no such thing as a free lunch.<br>
But spreading the work over each add call is a net win in almost any circumstance.<br>

![6](/images/img14.png "test5")
Benefits of SLList vs. IntList so far:<br>
- Faster size() method than would have been convenient for IntList.
- User of an SLList never sees the IntList class.
  - Simpler to use.
  - More efficient addFirst method (see exercises).
  - Avoids errors (or malfeasance):
   - 比如直接访问到的话会出现
   ```java
   SLList L = new SLList(15);
   L.addFirst(10);
   L.first.next.next = L.first.next;
    //下一个指针指到自己
   ```


Another benefit we can gain:<br>
- Easy to represent the empty list. Represent the empty list by setting first to null. Let’s try!
- We’ll see there is a very subtle bug in the code. It crashes when you call addLast on the empty list.<br>

addLast的时候会出错，因为first==null.<br>
方法1：加一个判断<br>
```java
   public void addLast(int x) {
   size += 1;

   if (first == null) {//👓
      first = new IntNode(x, null);
      return;
   }

   IntNode p = first;
   while (p.next != null) {
      p = p.next;
   }

   p.next = new IntNode(x, null);
}
```
这样让代码变复杂了，一点ugly；<br>
How can we avoid special cases?<br>
Make all SLLists (even empty) the “same”.<br>
Create a special node that is always there! Let’s call it a “sentinel node”.<br>

```java
public class SLList {
   private class IntNode {
      public int item;
      public IntNode next;
      public IntNode(int i, IntNode n) {
         item = i;
         next = n;
      }
   }

   /** The first item (if it exists) is at sentinel.next. */
   private IntNode sentinel;
   private int size;

   public SLList(int x) {
      sentinel = new IntNode(63, null);
      sentinel.next = new IntNode(x, null);
      size = 1;
   }

   /** Creates an empty SLList. */
   public SLList() {
      sentinel = new IntNode(63, null);
      size = 0;
   }


   /** Adds x to the front of the list. */
   public void addFirst(int x) {
      sentinel.next = new IntNode(x, sentinel.next);
      size += 1;
   }

   /** Returns the first item in the list. */
   public int getFirst() {
      return sentinel.next.item;
   }

   /** Adds an item to the end of the list. */
   public void addLast(int x) {
      size += 1;
      IntNode p = sentinel;

      /** Move p until it reaches the end of the list. */
      while (p.next != null) {
         p = p.next;
      }

      p.next = new IntNode(x, null);
   }

   /** Returns the size of the list. */
   public int size() {
      return size;
   }

   public static void main(String[] args) {
      SLList L = new SLList();
      L.addLast(20);
      System.out.println(L.size()); // should print out 1
   }
}

```

![7](/images/img15.png "test6")

## DLLists and Arrays

We added .last. What other changes might we make so that remove is also fast?<br>
Add backwards links from every node.<br>
This yields a “doubly linked list” or **DLList**, as opposed to our earlier “singly linked list” or SLList.<br>
<br>
While fast, adding .last and .prev introduces lots of special cases.<br>
To avoid these, either:<br>
Add an additional sentBack sentinel at the end of the list.<br>
Make your linked list circular (highly recommended for project 1), with a single sentinel in the middle.<br>

### lab2里学到的：
```java
    public static boolean squarePrimes(IntList lst) {
        // Base Case: we have reached the end of the list
        if (lst == null) {
            return false;
        }

        boolean currElemIsPrime = Primes.isPrime(lst.first);

        if (currElemIsPrime) {
            lst.first *= lst.first;
        }

        return currElemIsPrime || squarePrimes(lst.rest);  
        //这个地方用到 ||短路求值的特点，保证递归🤟
    }
```

## Testing

https://github.com/google/truth<br>

![8](/images/img16.png "test7")

### Java里string作为参数传递的情况<br>
在 Java 中，`String` 是一个特殊的、不可变的对象。它的管理方式有点不同，特别是在处理字符串常量时，会用到**字符串常量池（String Pool）**。

#### 1. **字符串常量池**
Java 为了优化内存使用，引入了一个叫做**字符串常量池**（也叫**字符串池**）的机制。字符串常量池是堆内存中的一个特殊区域，存储了一些字符串字面量（即直接定义在代码中的字符串常量）以及其他使用 `String.intern()` 方法生成的字符串。

#### 2. **`String` 赋值时的常量池查找机制**
当你使用**字面量**（比如 `"Hello"`）为一个 `String` 变量赋值时，Java 会先检查字符串常量池中是否已经有这个字符串：

- 如果常量池中已经存在相同内容的字符串，直接**返回池中的引用**，而不会再创建新的对象。
- 如果常量池中没有这个字符串，Java 会在常量池中**创建一个新的字符串对象**，并返回它的引用。

例如：
```java
String s1 = "Hello";  // "Hello" 被存储到常量池中
String s2 = "Hello";  // 直接从常量池中获取 "Hello" 的引用

System.out.println(s1 == s2);  // true，因为 s1 和 s2 指向同一个常量池中的字符串
```

在这个例子中，`s1` 和 `s2` 都指向常量池中的同一个 `"Hello"` 字符串。

#### 3. **通过 `new String()` 创建字符串**
当你使用 `new String("Hello")` 来创建字符串时，Java 不会使用常量池，而是**直接在堆内存中创建一个新的 `String` 对象**，即使 `"Hello"` 已经存在于常量池中。

例如：
```java
String s1 = "Hello";             // 常量池中的字符串
String s2 = new String("Hello");  // 在堆中创建一个新的对象

System.out.println(s1 == s2);  // false，s1 和 s2 指向的是不同的对象
```

在这种情况下，`s1` 指向常量池中的 `"Hello"`，而 `s2` 是在堆中创建的新对象，因此 `s1 == s2` 返回 `false`，因为它们是不同的对象。

#### 4. **`intern()` 方法**
如果你希望将一个通过 `new String()` 创建的字符串放入常量池或获取常量池中已有的字符串引用，可以使用 `intern()` 方法。`intern()` 方法会检查常量池中是否已经存在该字符串，如果存在则返回常量池中的引用；如果不存在，则会将该字符串添加到常量池中并返回引用。

```java
String s1 = new String("Hello");
String s2 = s1.intern();  // s2 将指向常量池中的 "Hello"
String s3 = "Hello";

System.out.println(s2 == s3);  // true，s2 和 s3 指向常量池中的同一个字符串
```

#### 总结
- **字面量赋值**：`String` 变量通过字面量赋值时，Java 会优先在字符串常量池中查找该字符串，避免重复创建相同的字符串对象。
- **`new String()`**：每次都会在堆中创建一个新的对象，而不依赖常量池。
- **`intern()`**：可以将堆中的字符串加入常量池，或获取常量池中的已有字符串。

https://blog.csdn.net/qq_48078182/article/details/121180265<br>

## ALists，Resizing,vs.SLists

![80](/images/img18.png "test18")
![88](/images/img19.png "test19")
![20](/images/img20.png "test20")

一个改善的方法：<br>
An AList should not only be efficient in time, but also efficient in space.<br>
- Define the “usage ratio” R = size / items.length;
- Typical solution: Half array size when R < 0.25.

### Generic ALists (similar to generic SLists)
```java
//对比：
public class AList {
  private int[] items;    
  private int size;
 
  public AList() {
    items = new int[8];  
    size = 0;
  }
 
  private void resize(int capacity) {
    int[] a = new int[capacity];
    System.arraycopy(items, 0, 
                     a, 0, size);
    items = a;
  }

  public int get(int i) {
    return items[i];
  }
...

public class AList<Glorp> {
  private Glorp[] items;    
  private int size;
 
  public AList() {
    items = (Glorp []) new Object[8];  
    size = 0;
  }
 
  private void resize(int cap) {
    Glorp[] a = (Glorp []) new Object[cap];
    System.arraycopy(items, 0, 
                     a, 0, size);
    items = a;
  }

  public Glorp get(int i) {
    return items[i];
  }
...

```

### Nulling out deleted items:
![21](/images/img21.png "test21")

## Interface and Implementation Inheritance
java也有method overloading,支持同名函数<br>
```java
public static String longest(AList<String> list) {
  	...
}

public static String longest(SLList<String> list) {
  	...
}

```
but<br>
- Code is virtually identical. Aesthetically gross.
- Won't work for future lists. If we create a QList class, have to make a third method.
- Harder to maintain.
  - Example: Suppose you find a bug in one of the methods. You fix it in the SLList version, and forget to do it in the AList version.

### Hypernyms, Hyponyms, and Interface Inheritance
//关键词 interface 指明这是接口，**列出所有可以做的事情，但是不给具体实现**
```java
public interface List61B<Item> {
   public void addFirst(Item x);
   public void addLast(Item y);
   public Item getFirst();
   public Item getLast();
   public Item removeLast();
   public Item get(int i);
   public void insert(Item x, int position);
   public int  size();
}
```

//关键词 implements 实现接口，一个类实现接口时需要给出**所有**功能具体实现
//Subclasses must override all of these methods!
```Java
public class AList<Item> implements List61B<Item>{
   ...
   public void addLast(Item x) { }
   }
```

//修改之后的 can work on either kind of list
```java
public static String longest(List61B<String> list) {
  	int maxDex = 0;
  	for (int i = 0; i < list.size(); i += 1) {
     	String longestString = list.get(maxDex);
     	String thisString = list.get(i);
     	if (thisString.length() > longestString.length()) {
        	maxDex = i;
     	}
  	}

  	return list.get(maxDex);
}

//使用eg:
AList<String> a = new AList<>();
a.addLast(“egg”); a.addLast(“boyz”);
longest(a);
```

![22](/images/img22.png "test22")
可以用 @override，这样不是正确重载会报错<br>

#### Interface Inheritance

default method<br>
```java
public interface List61B<Item> {
   public void addFirst(Item x);
   public void addLast(Item y);
   public Item getFirst();
   public Item getLast();
   public Item removeLast();
   public Item get(int i);
   public void insert(Item x, int position);
   public int size();  
   default public void print() {//subclass也可以继承这个实现，有需要重写就行
      for (int i = 0; i < size(); i += 1) {
         System.out.print(get(i) + " ");
      }
      System.out.println();
   }
}

```
![23](/images/img23.png "test23")
把LivingThing看成小盒子，它是static,new出来的Fox是动态的，最后一步变成new Squid()，所以动态的类型变成Squid了。<br>
![24](/images/img24.png "test24")
两个praise的参数是不一样的<br>

Another way to think about dynamic method selection is as a 2 step process🤟, where step 1 happens at compile time, and step 2 happens at runtime.<br>

These two steps obey rules that are easy to apply, but take time to understand.<br>
- At compile time: We determine the signature S of the method to be called.
S is decided using ONLY static types.
- At runtime: The dynamic type of the invoking object uses its method with this exact signature S.
By “invoking object”, we mean the object whose method is invoked.

上图的例子：<br>
第一步：<br>
- a.greet(d);  a的static type是Animal,所以是default void greet(Animal a);
- a.sniff(d);  a的static type是Animal,所以是default void sniff(Animal a);
- d.praise(d);  d的static type是Dog,但是dog类有两个praise，显然 void praise (Dog a)更符合
- a.praise(d);  a的static type是Animal,所以是default void praise(Animal a);

第二步：<br>
- Invoking object is a.a的dynamic type是Dog，So use Dog’s greet(Animal)
- Invoking object is a.a的dynamic type是Dog，So use Dog’s sniff(Animal)
- Invoking object is d.a的dynamic type是Dog，So use Dog’s praise(Dog a)
- Invoking object is a.a的dynamic type是Dog，So use Dog’s praise(Animal)





