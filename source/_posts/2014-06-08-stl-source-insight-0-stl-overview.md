---
layout: post
title: "深入理解STL源码(0) STL简介"
date: 2014-06-08 21:39
comments: true
categories: Program
tags: C++ STL
---
## 0. 两个问题
在介绍 STL 之前，先讨论两个问题：为什么要剖析 STL 源代码？如何剖析 STL 源代码？  

首先是为什么要剖析 STL 源代码呢？ 有人会说，会使用 STL 不就性了，为什么一定要知道其内部的机制呢？ 对于大多数程序猿来说，确实没有必要去阅读或分析 STL 的源代码，但如果要想提升自己的编程修养，要相让自己编码的思想境界提升一个档次，还是很有必要读读 STL 这样的大师制作。阅读和分析之后，你会明白STL是如何分配和管理内存的（特别是对vector、string、deque等动态数据结构），是如何实现各种数据结构（特别是红黑树等比较复杂的数据结构）和相关算法的，又是如何将这些组件融合起来实现高内聚低耦合的。或许用《洋葱》的几句歌词获取最能表达你的明白这些问题之后的心情：  

> 如果你愿意一层一层  
> 一层的剥开我的心  
> 你会发现  
> 你会讶异  
> 你是我  
> 最压抑  
> 最深处的秘密  
>   
> 如果你愿意一层一层  
> 一层的剥开我的心  
> 你会鼻酸  
> 你会流泪  
> 只要你能  
> 听到我  
> 看到我的全心全意  

那么，如何剖析源代码呢？其实歌词中已经蕴含这答案了，那就是“一层一层一层的剥开”。当然，我这里说的一层一层不是说要一个函数step in 到底，而是说要按层次解读：首先从最外层结构框架着手，从整体上把握；然后从细处着笔，一个组件一个组件的来分析；在分析每个组件时，也是先把握改组件的全貌及其与其他组件的关联关系，然后在深入组件内部，了解其实现。在阅读和分析源码的过程中，首先要理解其功能，然后在看它是如何实现的。切忌纠缠于代码的细节或陷入源码而不能自拔，即坠入“不识庐山真面目，只缘身在此山中”的深渊！  

因此，本文的目的在于，站在STL这座大山的山顶，一窥其全貌。随后的文章则深入每个组件，细细观赏每一处的风景。  

<!-- more -->

## 1. STL 简史
声明：这里的内容主要来自[Wiki中文网](http://zh.wikipedia.org/)，这里尽量简化其描述，虽然是尽量剪裁，但可能还是有些罗嗦，而且大段copy，掩面 ~(@&and;-&and;@)~  

STL 是 Standard Template Library（标准模板库）的缩写。Standard 是指STL是C++标准程序库的一部分，Template是指STL是一套模板，这也是STL最本质的特征。标准模板库使得C++编程语言在有了同Java一样强大的类库的同时，保有了更大的可扩展性。  

标准模板库系由 [Alexander Stepanov](http://en.wikipedia.org/wiki/Alexander_Stepanov) 创造于1979年前后，这也正是 [Bjarne Stroustrup](http://en.wikipedia.org/wiki/Bjarne_Stroustrup) 创造C++的年代（非常巧的是，这两为大师都出生于1950年）。  

Stepanov早期从事教育工作，在20世纪70年代就开始研究泛型程序设计了。1983年，Stepanov先生转至Polytechnic大学教书，继续研究泛型程序设计，同时写了许多Scheme的程序，应用在graph与network的算法上。1985年又转至GE公司专门教授高级程序设计，并将graph与network的Scheme程序，改用Ada写，用了Ada以后，他发现到一个动态（dynamically）类型的程序（如Scheme）与强制（strongly）类型的程序（如Ada）有多么的不同。在动态类型的程序中，所有类型都可以自由的转换成别的类型，而强制类型的程序却不能。但是，强制类型在出错时较容易发现程序错误。  

1988年Stepanov先生转至HP公司运行开发泛型程序库的工作。此时，他已经认识C语言中指针(pointer)的威力，他表示一个程序员只要有些许硬件知识，就很容易接受C语言中指针的观念，同时也了解到C语言的所有数据结构均可以指针间接表示，这点是C与Ada、Scheme的最大不同。Stepanov认为，虽然C++中的继承功能可以表示泛型设计，但终究有个限制。虽然可以在基础类型（superclass）定义算法和接口，但不可能要求所有对象皆是继承这些，而且庞大的继承体系将降低虚拟（virtual）函数的运行效率，这便违反了所谓的“效率”原则。  

在C++标准及C++模板概念的标准化过程中，Stepanov参加了许多有关的研讨会，并与C++之父Bjarne讨论模板的设计细节。Stepanov认为C++的函数模板（function template）应该像Ada一样，在声明其函数原型后，应该显式的声明一个函数模板之实例（instance）；Bjarne则不然，他认为可以通过C++的重载（overloading）功能来表达。几经争辩，Stepanov发现Bjarne是对的。  

事实上，C++的模板，本身即是一套复杂的宏语言（macro language），宏语言最大的特色为：所有工作在编译时期就已完成。显式的声明函数模板之实例，与直接通过C++的重载功能隐式声明，结果一样，并无很大区别，只是前者加重程序员的负担，使得程序变得累赘。  

1992年Meng Lee加入Alex的项目，成为另一位主要贡献者。1992年，HP泛型程序库计划退出，小组解散，只剩下Stepanov先生与Meng Lee小姐（她是东方人，标准模板库的英文名称其实是取STepanov与Lee而来），Lee先前研究的是编译器的制作，对C++的模板很熟，第一版的标准模板库中许多程序都是Lee的杰作。  

1993年，Andy Koenig到斯坦福演讲，Stepanov便向他介绍标准模板库，Koenig听后，随即邀请Stepanov参加1993年11月的ANSI/ISO C++标准化会议，并发表演讲。Bell实验室的Andrew Koenig于1993年知道标准模板库研究计划后，邀请Alex于是年11月的ANSI/ISO C++标准委员会会议上展示其观念。并获得与会者热烈的回应。  

1994年1月6日，Koenig寄封电子邮件给Stepanov，表示如果Stepanov愿意将标准模板库的说明文件撰写齐全，在1月25日前提出，便可能成为标准C++的一部份。  

Alex于是在次年夏天在Waterloo举行的会议前完成其正式的提案，并以百分之八十压倒性多数，一举让这个巨大的计划成为C++ Standard的一部份。   

标准模板库于1994年2月年正式成为ANSI/ISO C++的一部份，它的出现，促使C++程序员的思维方式更朝向泛型编程（generic program）发展。  

目前，常见的STL实现版本有HP(Hewlett-Packard Company) STL，P.J Plauger版，Rouge Wave版，STLport版，SGI(Silicon Graphics Computer System .Inc) STL版等。  

## 2. STL 六大组件  
STL的官方文档将STL划分成了五个主要部分，分别是Containers（容器）、Iterators（迭代器）、Algorithms（算法）、函数对象（Function Objects）、空间分配（Memory Allocation）。而在侯姐的《STL源码剖析》中，还有一个组成部分是Adaptors（适配器）。本文也按照侯姐的规范将STL分为六个部分，而且介绍的顺序也按照他的书中的顺序来介绍。（PS：这里只是简要介绍六大组件的主要功能，真的很简要哦）  

#### 2.1 Memory Allocation  
负责空间配置与管理，本质是实现动态空间配置、空间管理、空间释放的一系列class template。它是容器的底层接口，实际使用STL的用户是看不到Allocation的。  

#### 2.2 Iterators  
迭代器扮演容器与算法之间的胶合剂，可以形象的理解为“泛型指针”。从实现的角度看，迭代器是一种将operator*、operator->、operator++、operator--等指针相关操作进行重载的class template。所有的STL容器都有自己专属的迭代器——是的，只有容器设计者才知道如何遍历自己的元素，原生指针（Native pointer）也是一迭代器。  

#### 2.3 Containers  
容器可以理解为各种数据结构，如vector、list、deque、set、map等用来存放特定结构的数据的容器，也是一系列的class template。对于普通用户而言，容器是最熟悉不过了，我们最经常使用的容器主要有 vector, queue, stack, deque, map。相信很多人对 STL 的接触是从使用容器开始的，也有很多人对 STL 印象最深刻的就是容器了。   

#### 2.4 Algorithm  
主要是各种常用的算法，如sort、search、copy、erase、unique等。从实现的角度看，STL算法是一种function template。其中 sort 相信很多人并不陌生，在很多算法中我们都需要对数据进行排序。  

#### 2.5 Function Objects  
函数对象的行为类似函数，但可作为算法的某种策略（policy）。从实现的角度看，函数对象是一种重载了operator()（函数调用操作符）的class或class template。  

#### 2.6 Adaptors  
适配器是一种用来修饰容器或函数对象或迭代器的东西。例如，STL 提供queue和stack，虽然他们看似容器，但其实只能算是一种容器适配器，因为他们的底层实现完全借助于deque，所有的操作都由底层deque提供。改变functor/container/iterator的接口者称为functor/container/iterator adaptor。  

## 3. STL 各组件间的关系  
STL 六大组件间的关系如下图（来自侯姐《STL源码剖析》一书 p6）：  
{% img /images/2014/IMAG2014060801.jpg %}  
其中 Container 通过 Allocator 取得数据存储空间，Alogrithm 通过 Iterator 存取 Container 内容，Functor 可以协助 Algorithm 完成不同的策略变化，Adapter 可以修饰或套接 Functor。这里的描述有些抽象，等详细了解了每个组件的功能职责后，就比较好懂了。  

## 4. SGI STL源码结构  
最后，这里简单介绍一下SGI STL 源码的结构。我下载的是[SGI-STL-v3.3](https://www.sgi.com/tech/stl/download.html)， 它是基于1994年HP版STL改造而成的，最新版本v3.3的更新时间是2000年6月8日，共91个文件（SGI-STL官网文档中只列出了90个文件，少列了`vector.h`这个文件），1.1M大小（其实总代码量并不是很大，非常轻量级 (\*&and;-&and;\*) ，比较适合拿来彻底分析一遍 ）。  

在这91个文件中，有**37个**以 `stl_` 开头的文件，这些都是STL内部实现文件。有**23个**无扩展名的文件，这些都是STL对外提供的标准接口。 有**11个**与无扩展名文件同名的.h文件，这是对应的old-style形式的头文件（至于为什么不是每个无扩展名（new-style）头文件都有对应的 `.h` 文件，我也不太清楚）。 还有**20个**文件，主要是为 `stl_` 开头的文件提供比较 common 的功能，如 `algobase.h`、`hashtable.h` 等，或者是对 `stl_` 开头的文件进行一次内部封装，还有其他一些杂项功能等。  

## 5. 参考及推荐  
### 推荐阅读  
介绍STL模板的书，有两本比较经典：  
一本是《Generic Programming and the STL》，中文翻译为《泛型编程与STL模板》，这本书由STL开发者 Matthew H.Austern编著，由STL之父Alexander Stepanov等大师审核的，介绍STL思想及其使用技巧，适合初学者使用。  
另一本书是《STL源码剖析》，是《深入浅出MFC》的作者侯捷编写的，介绍STL源代码的实现，适合深入学习STL，不适合初学者。  
### 源码阅读与分析工具  
能在Linux下用熟练使用vim最好了，实在不行用 Code::Blocks 也挺不错的，可以查找函数原型、定义、调用等。在Windows下用Source Insight最好了，可惜不是免费的，但同样也可以用Code::Blocks 或 Visual C++ Express 等 IDE。  
原本想用一个UML建模工具来分析一下STL中的类之间的关系的，但是看了看源代码，基本没有太多的继承之类的关系，而且很多UML工具对C++源码自动生成类图的功能支持得并不好，就放弃了。  
### 参考  
\[1] [Wiki: Standard Template Library](http://en.wikipedia.org/wiki/Standard_Template_Library)   
\[2] [Wiki: 标准模板库](http://zh.wikipedia.org/wiki/%E6%A0%87%E5%87%86%E6%A8%A1%E6%9D%BF%E5%BA%93)   
\[3] [Standard Template Library Programmer's Guide](https://www.sgi.com/tech/stl/)   
\[4] [如何看懂源代码--(分析源代码方法)](http://www.cnblogs.com/todototry/archive/2009/06/21/1507760.html)   

