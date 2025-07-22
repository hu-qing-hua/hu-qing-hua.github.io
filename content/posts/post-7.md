---
title: "MIT-6.824-2025Spring-Lab1/2/3踩坑记录"
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

### lab3 Raft
#### 3A 3B
思路：我使用的是无缓冲的通道来判断状态state转换 ，在Raft结构体里加入如下变量
```go
state             State
    toFollowerCh      chan struct{}
    toCandidateCh     chan struct{}
    toLeaderCh        chan struct{}
    toAppendEntriesCh chan struct{}
    toVoteSuccessCh   chan struct{}
```
用通道的好处是cpu开销几乎无开销，事件触发式；
所以虽然相比时间戳的方式，需要考虑上一轮里写入通道的残留数据会不会影响这次的状态判断，但我还是舍不得通道的性能优势。
比如
```go
switch state {
case Follower:
            rf.drainChannel(rf.toAppendEntriesCh)//清空表示收到leader心跳的信号通道
            rf.drainChannel(rf.toVoteSuccessCh)//清空表示收到投票请求并成功投票的信号通道
            select {
            case <-rf.toAppendEntriesCh:
                //进入可能的原因1.在ms结束前有收到leader消息
                //log.Printf("term %d peer %d get appendentries", rf.currentTerm, rf.me)
                continue
            case <-rf.toVoteSuccessCh:
                //进入可能原因1：接收到投票请求并且返回投票成功
                //log.Printf("term %d peer %d vote to %d success", rf.currentTerm, rf.me, rf.votedFor)
                continue
            case <-time.After(time.Duration(ms) * time.Millisecond):
                //log.Printf("term %d peer %d start election as a follower", rf.currentTerm, rf.me)
                rf.startElection(Follower)
            }
...
}
```
这里在每次进入case Follower的时候，我都会执行一次drainChannel操作。
如果没有清空这一步，可能发生的极端情况如下：
1. 上一个 leader 还在时，发送了心跳，follower 收到并写入了 toAppendEntriesCh。
2. 这时 leader 崩溃了，但 toAppendEntriesCh 里还残留着上一次的心跳信号。
3. Follower 进入下一轮 select，会优先读取 channel，导致继续 continue，延迟了新一轮选举的开始。
而在表示状态的通道，我的处理是在每次切换不同State的时候，把别的状态信号通道清空，并写入一次新状态的通道 


<br>另外，hint里提到一条是实现GetState
```go
// return currentTerm and whether this server
// believes it is the leader.
func (rf *Raft) GetState() (int, bool) {
    // Your code here (3A).
    rf.mu.Lock()
    defer rf.mu.Unlock()
    return rf.currentTerm, rf.state == Leader
}
```
但这个是给在测试程序用的，但在写逻辑时，如果需要获取 currentTerm 并基于它执行后续操作，应在同一个加锁块中完成读取和操作。否则，如果先通过 GetState() 获取 currentTerm，再在解锁后执行相关逻辑，可能会因为状态变更而导致读取的 currentTerm 与实际状态不一致，从而引发决策滞后或逻辑错误
![alt text](/assets/07213a.png)
![alt text](/assets/07213b.png)
#### 3C
1. []T 这种类型是切片 默认是引用传递 
  [N]T 或者 [...]T 这种是数组 默认是值传递 
2. 刚开始我执行rf.UpdateLastApplied() （用于回应客户端）是在每次推进commitIndex之后（考虑到只有commitIndex改变之后才会需要修改lastApplied，这样也可以提高性能）
但是实际上这样会回应的不够及时，还是开了独立的协程执行 
3. 
```go
func (rf *Raft) Start(command interface{}) (int, int, bool) {
    index := -1
    term := rf.currentTerm
    isLeader := true
    rf.mu.Lock()
    defer rf.mu.Unlock()
    if rf.state != Leader {
        isLeader = false
        return index, term, isLeader
    }

    // Your code here (3B).
    index = rf.log[len(rf.log)-1].Index + 1
    term = rf.currentTerm
    rf.log = append(rf.log, LogEntry{Term: term, Index: index, Command: command})
    rf.persist()
    rf.sendHeartBeat()
    return index, term, isLeader
}
```
这里的index不是直接=len(rf.log)
是因为如果server崩溃之后读取的persist状态log和之前长度不一样的话，index会出现偏差
![alt text](/assets/0722.png)
#### 3D
1. 3D花了很长时间，实在不知道哪里出错了；没有想到会出现在做3D的过程中，修改到测试3C也通不过的情况，版本也没有及时保存；所以最终还是从finish3B的提交版本上重构。 
2. 3D需要持久化的内容多了lastIncludeIndex,lastIncludeTerm,Snapshot，在原先的改动上分为三部分
* 增加snapshot有关的函数
* 之前直接用的index 现在需要考虑如果已经有快照存储了，需要使用当前log里的索引
* 之前范围判断的条件需不需要增加考虑已经快照的部分怎么处理

3. 这里要注意对rf.lastApplied和rf.commitIndex更新不及时情况的处理
```go
func (rf *Raft) UpdateLastApplied() {
	for !rf.killed() {
		rf.mu.Lock()
		if rf.lastApplied < rf.lastSnapShotIndex {
			rf.lastApplied = rf.lastSnapShotIndex
		}
		if rf.commitIndex > rf.getLastIndex() {
			rf.commitIndex = rf.getLastIndex()
		}
		for rf.lastApplied < rf.commitIndex {
			nextIndex := rf.lastApplied + 1
			if nextIndex < rf.lastSnapShotIndex {
				rf.mu.Unlock()
				panic("BUG: trying to apply a log before snapshot")
			}
			logIdx := rf.getLogIndex(nextIndex)
			if logIdx >= len(rf.log) {
				rf.mu.Unlock()
				panic("BUG: log index out of range")
			}
			rf.lastApplied = nextIndex
			msg := raftapi.ApplyMsg{
				CommandValid: true,
				Command:      rf.log[logIdx].Command,
				CommandIndex: rf.lastApplied,
			}
			rf.mu.Unlock()
			rf.applyCh <- msg
			rf.mu.Lock()
		}
		rf.mu.Unlock()
		time.Sleep(10 * time.Millisecond)
	}
}
```
![alt text](/assets/0721.png)

最后重复10次test，都通过了

