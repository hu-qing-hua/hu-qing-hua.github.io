---
title: "用go实现Redis的功能"
date: 2025-08-08T02:01:58+05:30
description: "希望通过动手去做，可以让我更了解Redis，之后有需要再去读源码"
tags: [Note]
---
# 实现思路
![alt text](/assets/0927.png)


# 1.package app
## 作用
是goRedis这个程序运行的一个实例
```go
type App struct {
	server *server.Server
	conf   *Config
}
```
字段表示一个redis功能配置模块实例和一个server服务实例
提供给外界Run()和Stop()
## 细节
### dig 做依赖注入：
```go
var container = dig.New()

func init() {
	container.Provide(SetUpConfig)
	container.Provide(log.GetDefaultLogger)
	container.Provide(server.NewServer)
	......
}

func ConstructServer() (*server.Server, error) {
	var handler server.Handler
	if err := container.Invoke(func(_h server.Handler) {
		handler = _h
	}); err != nil {
		return nil, err
	}

	var logger log.Logger
	if err := container.Invoke(func(_l log.Logger) {
		logger = _l
	}); err != nil {
		return nil, err
	}
	return server.NewServer(handler, logger), nil
}
```
在使用过程中不断尝试解决了我的疑惑,以QA方式记录： 
1. 
Q:dig怎么知道调用什么函数创建对应的实例？   
A:dig会建立类型到函数的映射表，用户指明了创建函数  
eg :
```go
_ = container.Provide(handler.NewHandler)  // 提供server.Handler
```
由于这个函数的返回值是
```
func NewServer(handler Handler, logger log.Logger) *Server
```
所以*server.Server -> server.NewServer

2. 
Q:如果我在使用过程中先注册了server，会因为在这之前没有注册server需要的接口而无法创建吗？ 
eg: 
```go
//先注册Server,再注册它需要的Handler和Logger
_ = container.Provide(server.NewServer)
_ = container.Provide(handler.NewHandler)  
_ = container.Provide(log.GetDefaultLogger)
```
A:dig是惰性加载机制，注册依赖之后是在Invoke按需加载, 
eg： 
当调用container.Invoke(func(s *server.Server) { ... })时： 
 1. dig分析发现需要*server.Server 
 2. 找到提供者server.NewServer(handler.Handler, log.Logger) 
 3. 递归分析参数依赖： 
 4. 发现需要server.Handler和log.Logger 
 5. 按依赖关系创建： 
 6. 先创建log.Logger 
 7. 再创建server.Handler 
 8. 最后创建*server.Server 

所以依赖注册的顺序不重要，因为在注册的时候并没有创建实例。即使先注册server，在创建的时候也能找到对应的handler和logger依赖 
但是如果只注册server.NewServer而不注册它需要的依赖eg：Handler，在调用时会失败。 

3. dig采用单例模式：
```go
func ConstructServer() (*server.Server, error) {
	var h server.Handler
	if err := container.Invoke(func(_h server.Handler) {
		h = _h
	}); err != nil {
		return nil, err
	}

	var l log.Logger
	if err := container.Invoke(func(_l log.Logger) {
		l = _l
	}); err != nil {
		return nil, err
	}
	return server.NewServer(h, l), nil
}
```
 1. 开始我想dig要创建server.Handler是怎么做的，难道它要先创建server，然后再传入server里的handler吗? 
后来发现dig创建是根据类型，它解析了 server.Handler 发现这个类型其实和依赖里注册的handler.NewHandler一致， 
那么它知道这里实际要创建的是一个handler,并没有说会先去创建server 
 2. 由于单例模式，那之后我想invoke调用一个handler类型的时候，dig返回的实例 
其实也是在constructServer里被当作server接口的handler实例；要注意不要出现数据污染的情况

### sync.Once
https://victoriametrics.com/blog/go-sync-once/ 关于现在的sync.Once实现方式讲的好好
### reflect库
go里的reflect库居然可以用tag实现自定义的name,我之前用cpp做反射的时候都只能用变量名
```go
//我在结构体声明的时候已经加了tag,kv存储的时候可以用tag的信息
		key, ok := field.Tag.Lookup("cfg") //取tag
		if !ok || strings.TrimSpace(key) == "" {
			//如果没有tag，就用字段名
			key = field.Name
		}
```
# 2. package server
## 作用
1. 负责监听tcp连接发来的消息，为每个请求创建一个gorountine,放到协程池
2. 协程池里有一个特殊的gorountine负责监听什么时候关闭server
	1. 有一个注册监听挂起，退出，终止，中断的信号，信号写入channel
	2. app.Stop()被调用的时候
	3. 请求处理报错
## 细节 
1. 
```go
//创建一个可以取消的上下文
	//ctx会传递给每一个处理连接的协程
	//当调用cancel时，ctx会被取消，所有用到ctx的协程都会收到通知
	ctx, cancel := context.WithCancel(context.Background())
```
因为如此才能在监听要关闭server的时候及时关闭其他所有在处理的线程 
2. conn, err := listener.Accept() 这里是一个tcp连接 
本地就可以建立多次tcp连接：（操作系统会自动分配源端口） 
第一个redis-cli  
redis-cli -h localhost -p 6379  # 源端口: 54321 → 目标端口: 6379  

第二个redis-cli（新终端）    
redis-cli -h localhost -p 6379  # 源端口: 54322 → 目标端口: 6379 ß  

第三个redis-cli（新终端）  
redis-cli -h localhost -p 6379  # 源端口: 54323 → 目标端口: 6379  

# 3. package handler
## 作用
处理并完成请求
## 细节
### 匿名字段
普通来说如果想让*fakeReadWriter是一个合法的io.ReadWriter，需要实现Reader和Write接口
```go
type fakeReadWriter struct {
    r io.Reader
}

func (f *fakeReadWriter) Read(p []byte) (int, error) {
    return f.r.Read(p)
}

func (f *fakeReadWriter) Write(p []byte) (int, error) {
    return 0, nil
}
```
但是也可以通过匿名嵌入接口
```go
type fakeReadWriter struct {
	io.Reader
}

func newFakeReaderWriter(reader io.Reader) io.ReadWriter {
	return &fakeReadWriter{
		Reader: reader,
	}
}

func (f *fakeReadWriter) Write(p []byte) (n int, err error) {
	return 0, nil
}
```
### RESP
Redis协议规范（RESP - REdis Serialization Protocol）： 
所有Redis命令都必须以数组格式发送 
数组格式以 * 开头，后面跟数组元素个数 
每个元素都是定长字符串格式（以 $ 开头） 
### ReadBytes
原始数据: "$5\r\nhello\r\n"
```go
firstLine, err := reader.ReadBytes('\n')
```
reader.ReadBytes('\n') 读取 → "$5\r\n" 
剩余数据在reader中: "hello\r\n" 
# 4. package persist

# 5. package dataBase

# 6. package dataStore

# 8. package pool
## 细节
1. func init()是go里的生命周期钩子，包导进去的时候会自动调用
2. 
```go
case <-s.stopc:
``` 
stopc是一个channel,这个触发会有两种情况 
  1. 有人往 channel 写数据：s.stopc <- struct{}{}。
  2. channel 被关闭：close(s.stopc)。
3. 
```go
func (s *Server) listenAndServe(listener net.Listener, closec chan struct{})
```
listener：是接口，传递的是接口值（里面有指针），所以调用 listener.Accept() 仍然作用在同一个 Listener 上。
closec：是 channel，本质上就是个指针，所以传进去和外面的用的是同一个 channel。
4. gorountine在阻塞的时候CPU占用几乎为0,会挂起，有点像监听机制

# 9. package log
## 作用
redis日志打印
## 细节
### 初始化方法：函数式选项
好优雅，cpp里的话可能就是一长串参数的构造函数了
```go
// 参数是*Options类型，没有返回值的函数，做的是修改参数对象
type OptionFunc func(*Options)

// 初始化
func NewOptions(opts ...OptionFunc) Options {
	options := Options{
		LogName:    "app",
		LogLevel:   "info",
		FileName:   "app.log",
		MaxAge:     10,
		MaxSize:    100,
		MaxBackups: 3,
		Compress:   true,
	}
	for _, opt := range opts {
		opt(&options)
	}
	return options
}
```
### zap/lumberjack
log/ log rotation
