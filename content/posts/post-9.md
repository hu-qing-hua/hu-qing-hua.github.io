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
![alt text](Untitled-2025-04-17-1257.png)
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

