---
title: "go-zero源码阅读笔记"
date: 2025-09-08T02:01:58+05:30
description: "起因是在使用go-zero的过程中，想知道它提供的某些功能是怎么实现的，所以打算看看，未来也会继续更新。"
tags: [Note]
---
# /core/mr
实现了一个并行的接口
## func MapReduce：
我之前阅读 MapReduce 论文并实现了一个统计字符串的具体任务，mr包里的实现的更通用，思想是一样的。
![alt text](/assets/Untitled-2025-04-17-1257.png)
保证安全性: 
1. MapReduce里的参数：panicChan := &onceChan{channel: make(chan any)},在执行全过程里都会监听这个管道的写入情况，出错就把错误信息写进去，并且通过atomic管理一个变量保证管道只写入一次
2. Option参数可以设置当前函数的context,全程监听context Done()是否执行
Q&A: 
1.因为generate执行的协程里数据全写到source chan后就会close(source),
但是在excutemapper里有一个协程池pool := make(chan struct{}, mCtx.workers)
有空的缓冲区的时候会一直尝试读取source里的函数进行工作。
Q:万一source里的数据没读完就被close了怎么办
A:关闭channel不会清空数据，可以一直读，空了item, ok := <-mCtx.source才会返回失败
## 其他函数
mr里的别的函数：例如finish(fns ...func() error)error，本质上是把一个包装好的MapReduce的调用：
 1.func1、func2...这些函数当作数据写入generate里的source，
 2.写好mapper函数内容：执行“数据”，报错就调用cancel()
 3.reduce函数写空

## 实现细节上学习到的:
1. go里的闭包捕获是自动的，不需要写明，而且是引用捕获
2. 看到go里的泛型，和c++模板元编程相比，泛型做不到编译时计算
3. 
```go
type onceChan struct {
	channel chan any
	wrote   int32
}

func (oc *onceChan) write(val any) {
	if atomic.CompareAndSwapInt32(&oc.wrote, 0, 1) {
		oc.channel <- val
	}
}
```
实现只写入一次的管道；
func CompareAndSwapInt32(addr *int32, old, new int32) bool
原子操作完成比较 *addr是否等于old，一致就更新 *addr=new,返回true;不一致就返回false

4. **options pattern** 可以用来配置复杂的参数
```go
type ConnectionOptions struct {
    Timeout int
    SSL     bool
}

// 选项函数类型
type Option func(*ConnectionOptions)

func WithTimeout(t int) Option {
    return func(o *ConnectionOptions) { o.Timeout = t }
}

func WithSSL(ssl bool) Option {
    return func(o *ConnectionOptions) { o.SSL = ssl }
}

// 构造函数通过选项配置
func NewConnection(opts ...Option) *Connection {
    options := &ConnectionOptions{Timeout: 10, SSL: false} // 默认值
    for _, opt := range opts {
        opt(options) // 应用选项
    }
    // 使用 options 初始化连接
    return options
}
```
5. 想创建一个可以被多次调用但是只执行一次逻辑的函数cancel：
```go
cancel := once(func(err error) {
		if err != nil {
			retErr.Set(err)
		} else {
			retErr.Set(ErrCancelWithNil)
		}

		drain(source)
		finish()
	})
func once(fn func(error)) func(error) {
	once := new(sync.Once)
	return func(err error) {
		once.Do(func() {
			fn(err)
		})
	}
}
```

# /zrpc/internal/balancer/p2c
go-zero 中，负载均衡算法 -- power of two choice 
![alt text](/assets/Untitled-2025-10-12-2031.png)
1. healthy检查：节点的success指标（通过EWMA算法计算）不能小于设好的阈值500
2. load负载算法：
```go
lag := int64(math.Sqrt(float64(atomic.LoadUint64(&c.lag) + 1)))
	load := lag * (atomic.LoadInt64(&c.inflight) + 1)
```
lag是延迟指标（EWMA算法计算），inflight是请求个数

3. 防止饥饿的操作
如果当前距离节点上次被pick已经超过阈值1s，就判断为饥饿状态，强制选择

**细节：**
在计算lag的时候需要知道这个节点完成上一次请求需要的时间，这里是通过闭包和h异步回调实现的
Pick函数返回如下
```go
return balancer.PickResult{
		SubConn: chosen.conn,
		Done:    p.buildDoneFunc(chosen),
	}, nil
```
在buildDineFunc里会先获取当前时间也就是被选中的时间start := int64(timex.Now())，然后buildDineFunc返回一个闭包。
当gRPC使用SubConn向对应节点发送请求后，节点处理完返回响应，此时Done函数被调用，也就是buildDineFunc返回的闭包函数被调用，在闭包里计算延迟lag := int64(now) - start

# 关于数据库和缓存操作
## 读操作接口
```go
func (cc CachedConn) QueryRowIndexCtx(ctx context.Context, v any, key string,keyer func(primary any)string, indexQuery IndexQueryCtxFn,primaryQuery PrimaryQueryCtxFn) error
```
**保证不会缓存击穿———core\syncx\singleflight.go**
原理是确保同一时间只有一个 goroutine 查询同一数据
```go
call struct {//请求
		wg  sync.WaitGroup
		val any
		err error
	}

flightGroup struct {//所有请求数据
		calls map[string]*call
		lock  sync.Mutex
	}
```
所有请求都用全局锁lock，对应key的请求只有一个c1能c1.wg.Add(1),执行操作返回结果写入val
其余相同key的请求：
```go
if c, ok := g.calls[key]; ok {
		g.lock.Unlock()
		c.wg.Wait()
		return c, true
	}
```
由于flightGroup.calls存储的是指针，所以其余请求只要先获取到c, ok := g.calls[key]，就可以进入等待状态。 
负责执行的c1在写入c1.val之后，<u>可以立即delete(g.calls, key)，这只是删除key对应的条目</u>，并没有把对象删了，因此其余请求return c,true是可以的 
C++里对应的是
```cpp
calls.erase("key");//只删除映射
delete ptr;//删除对象 
```

**防止缓存穿透 core\stores\cache**
![alt text](/assets/Untitled-1012.png)

## 更新操作
先更新数据库 
再删除对应的缓存
Q:为什么只删除不重新写入缓存
A:如果写入缓存这一步失败，会导致数据库和缓存不一致，所以只做删除，下次调到的时候再从数据库加载
