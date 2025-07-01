---
title: "MIT-6.824-2025Spring-Labs-Solutions"
date: 2025-06-08T02:01:58+05:30
description: "将学习过程中的收获记录下来，希望通过这个课程可以了解一些分布式系统设计的内容。"
tags: [Note]
---
### 做lab之前
#### 1.速成golang的基本语法
1. 一个data race的经典例子
```go
func main() {
	start := time.Now()
	var t *time.Timer
	t = time.AfterFunc(randomDuration(), func() {
		fmt.Println(time.Now().Sub(start))
		t.Reset(randomDuration())
	})
	time.Sleep(5 * time.Second)
}

func randomDuration() time.Duration {
	return time.Duration(rand.Int63n(1e9))
}
```
先看afterfunc的介绍 
“AfterFunc waits for the duration to elapse and then calls f in its own goroutine. It returns a Timer that can be used to cancel the call using its Stop method. The returned Timer's C field is not used and will be nil.”
所以这里可能的问题如下：duration太短了，导致回调的goroutine执行到reset,但是afterfunc的返回值timer还没有赋值给t。那么此时t是nil 调用reset会出错 
| 时间点 | 主 goroutine                    | 回调 goroutine                  |
| --- | ------------------------------ | ----------------------------- |
| t0  | 开始执行 `t = time.AfterFunc(...)` | -                             |
| t1  | `AfterFunc` 内部起一个新 goroutine   | -                             |
| t2  | `t = ...` 还没完成                 | goroutine 开始执行，使用 `t.Reset()` |
| t3  | `t = ...` 才完成                  | -                             |

ps：这里reset的作用是重新设置duration,修改f在回调goroutine里的触发时间，只有一个回调goroutine

### lab1 mapreduce
1. 看了论文和仓库代码，大概知道需要做什么，以下是我在做前理解的原理
![alt text](/assets/Untitled-2025-06-12-2031.png)
2. 踩的坑 ：
	1. 自定义的Reply结构体字段未导出（小写开头）因为**Go 的 net/rpc 只会序列化/反序列化大写开头的导出字段**。如果Reply结构体中的 splitName 字段是小写（如 splitName string），worker 端永远收不到值。
	2. 我开始以为通过FNV算法映射的int Y一定不同,因此每一个后缀Y相同的out中间文件保存的都是同一个key。
	但是lab提示//use ihash(key) % NReduce to choose the reduce，**通过%NReduce之后，不同key也可能映射到同一个Y,因此每个reduce任务需要处理的key也不止一种，每次reduce处理完可以将多个key的统计数据直接输出到结果文件**，这样确实更合理。
	3. 我开始以为reduce任务只要执行nReduce次左右，但实际运行起来发现经常出现超时重新派发执行的情况
	4. 我的设计是worker发生reduce请求，不清空reply而是让coordinator重新赋值一个key，然后worker直接从请求结果里读取需要处理的key.**但实际上这种操作会导致worker端出现多个key**，虽然逻辑上不应该有问题，因为只要能正常返回请求结果允许reduce，那必然是修改了key；但实际上 worker 端的 reply 变量没有被完全重置，导致上一次的 key 残留。所以要每次reply = Reply{}

3. ![alt text](/assets/0701.png)

### lab2 Key/Value Server
1. 稍微绘制了一下不同客户端是怎么通过kvServer实现共享锁的，图中三个client的lock使用同一个key，所以实际上它们上锁解锁都会去通过对server里的同一个键值操作，因此实现了互斥。
![alt text](/assets/0701(1).png)
2. 踩的坑 
   1.  刚开始错误示范 我定义的Lock结构体如下
```go
type Lock struct {
    // IKVClerk is a go interface for k/v clerks: the interface hides
    // the specific Clerk type of ck but promises that ck supports
    // Put and Get.  The tester passes the clerk in when calling
    // MakeLock().
    ck kvtest.IKVClerk
    // You may add code here
    l  string
    wg sync.WaitGroup
    mu    sync.Mutex // protects the state
    state string
}
```
在做task2的时候，我根据自己理解的实现效果用本地的state来判断lock状态，也能通过task2,是因为现在测试环境是单进程。
但**设计的目的是用KVserver存储所有共享的数据，lock只提供通用方法**。

   2. 发现这条hint没有用上也能通过所有测试
“You will need a unique identifier for each lock client; call kvtest.RandValue(8) to generate a random string.”
但是**如果不实现这条即给每个客户端都加上id唯一标识的话，那么只实现了对锁的互斥使用** 
这个时候release代码：
```go
func (lk *Lock) Release() {
    for {
        val, ver, err := lk.ck.Get(lk.l)
        if err == rpc.OK && val == "locked" {
            err := lk.ck.Put(lk.l, "unlocked", ver)
            if err == rpc.OK {
                return
            }
        }
        time.Sleep(100 * time.Millisecond)
    }
}
```
可能出现的问题是所有客户端都可以把锁释放了，即使不是由它上的锁，这样很危险。

3. ![alt text](/assets/0701(2).png)



