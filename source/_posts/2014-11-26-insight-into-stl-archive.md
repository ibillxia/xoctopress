---
layout: post
title: "深入理解STL源码系列文章归档"
date: 2014-11-26 18:19
comments: true
categories: Program
tags: C++ STL
---

前后花了大概快六个月的时间（从6月8日到11月23），终于把侯捷的《STL 源码剖析》看完了，同时也把 SGI 实现 STL 的最新版本看完了。在这段时间里，几乎是每个周末花大约一天的时间来看书和代码，并将相应内容在博客中加以归纳和总结。由于基本上都是在周末抽时间看的，所以周期拉得比较长，但收获还是挺多的，其中印象比较深刻的是 STL 中的迭代器与型别萃取、空间配置与内存池的实现、双端队列 (deque)  的实现、红黑树的实现、排序等算法的实现、类与函数的偏特化、函数对象与适配器等等，对 STL 的整体架构也有了比较深入的认识。这段时间也经历了很多事情，看书和代码的过程中也遇到了很多问题，有些经过反复琢磨自己解决了，还有些仍未完全弄清楚，需要再回过头去看一遍。另外，在看书和代码的过程中，基本没有去写代码、去实践，只停留在理论上，再看一遍的时候可以写些测试的代码或自己实现一个相应的模块或功能。  

这里再把之前写的深入理解 STL 源码的系列文章进行一个归档：  

#### STL 简介  
1. [深入理解STL源码(0) STL简介](http://ibillxia.github.io/blog/2014/06/08/stl-source-insight-0-stl-overview/)  

#### STL 空间配置器  
2. [深入理解STL源码(1) 空间配置器(allocator)](http://ibillxia.github.io/blog/2014/06/13/stl-source-insight-1-memory-allocator/)  

#### STL 迭代器  
3. [深入理解STL源码(2) 迭代器(Iterators)和Traits](http://ibillxia.github.io/blog/2014/06/21/stl-source-insight-2-iterators-and-traits/)  

<!-- more -->

#### STL 容器  
4. [深入理解STL源码(3.1) 序列式容器之vector](http://ibillxia.github.io/blog/2014/06/29/stl-source-insight-3-sequential-containers-1-vector/)  
5. [深入理解STL源码(3.2) 序列式容器之list](http://ibillxia.github.io/blog/2014/07/06/stl-source-insight-3-sequential-containers-2-list/)  
6. [深入理解STL源码(3.3) 序列式容器之deque和stack、queue](http://ibillxia.github.io/blog/2014/07/13/stl-source-insight-3-sequential-containers-3-deque-and-stack-queue/)  
7. [深入理解STL源码(3.4) 序列式容器之heap和priority queue](http://ibillxia.github.io/blog/2014/07/27/stl-source-insight-3-sequential-containers-4-heap-and-priority-queue/)  
8. [深入理解STL源码(4.1) 关联式容器之红黑树](http://ibillxia.github.io/blog/2014/08/03/insight-into-stl-4-associative-containers-1-red-black-tree/)  
9. [深入理解STL源码(4.2) 关联式容器之set和multiset](http://ibillxia.github.io/blog/2014/08/17/insight-into-stl-4-associative-containers-2-set-and-multiset/)  
10. [深入理解STL源码(4.3) 关联式容器之map和multimap](http://ibillxia.github.io/blog/2014/08/31/insight-into-stl-4-associative-containers-3-map-and-multimap/)  
11. [深入理解STL源码(4.4) 关联式容器之hashtable](http://ibillxia.github.io/blog/2014/09/13/insight-into-stl-4-associative-containers-4-hashtable/)  
12. [深入理解STL源码(4.5) 关联式容器之hashset和hashmap](http://ibillxia.github.io/blog/2014/09/27/insight-into-stl-4-associative-containers-5-hashset-and-hashmap/)  

#### STL 算法  
13. [深入理解STL源码(5.1) 算法](http://ibillxia.github.io/blog/2014/10/12/insight-into-stl-5-algorithm-1-overview/)  
14. [深入理解STL源码(5.2) 算法之数值算法](http://ibillxia.github.io/blog/2014/10/19/insight-into-stl-5-algorithm-2-numeric-algorithms/)  
15. [深入理解STL源码(5.3) 算法之基本算法algobase](http://ibillxia.github.io/blog/2014/10/25/insight-into-stl-5-algorithm-3-base-algorithms-algobase/)  
16. [深入理解STL源码(5.4) 算法之复杂算法algorithm](http://ibillxia.github.io/blog/2014/11/01/insight-into-stl-5-algorithm-4-relative-complexity-algorithms/)  

#### STL 函数对象  
17. [深入理解STL源码(6) 仿函数|函数对象](http://ibillxia.github.io/blog/2014/11/15/insight-into-stl-6-functor-or-function-objects/)  

#### STL 适配器
18. [深入理解STL源码(7) 配接器adaptor](http://ibillxia.github.io/blog/2014/11/23/insight-into-stl-7-adaptor/)  

接下来，还需要花大量时间来重温一遍，对之前文章中的一些遗留问题进行梳理和解答。

