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
java里地址都是64bit.<br>

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
        //这个地方用到 ||短路求值的特点
    }
```

感觉在GradeScope提交评分的过程,和之前在kaggle上提交一样，让我更有成就感。可能因为别人写好测试，通过评分我可以知道我的程序到底有没有问题。
