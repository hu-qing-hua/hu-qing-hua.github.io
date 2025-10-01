---
title: "记录最近接触到的线程池和内存池的原理"
date: 2025-04-09T02:01:58+05:30
description: "简单通过画图来解释思路"
tags: [Note]
---
线程池
![alt text](/assets/04091.png)
经常搭配std::future使用，可以处理异步的返回值和异常
内存池
![alt text](/assets/927.png)
内存池主要思想是提前预分配好一块大内存，由用户管理这块内存的分配和释放，减少频繁调用malloc/free，减少内存碎片