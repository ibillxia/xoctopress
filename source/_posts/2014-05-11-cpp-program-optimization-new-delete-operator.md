---
layout: post
title: "C++ 应用程序性能优化之 new/delete 操作符"
date: 2014-05-11 20:33
comments: true
categories: Program
tags: C++ Optimization Memory Pointer
---
## 1.概述
C++ 程序的存储空间可以分为静态/全局存储区、栈区和堆区。下图展示了一个典型的Linux C/C++ 程序内存空间布局：
<center>{% img /images/2014/IMAG2014051101.png %}</center>
其中，每一部分的具体涵义如下：  
- **代码段（.text）**：这里存放的是CPU要执行的指令。代码段是可共享的，相同的代码在内存中只会有一个拷贝，同时这个段是**只读**的，防止程序由于错误而修改自身的指令。  
- **初始化数据段（.data）**：这里存放的是程序中需要明确赋初始值的变量，例如位于所有函数之外的全局变量：`int val=100;` 。 需要强调的是，以上两段都是位于程序的可执行文件中，内核在调用 exec 函数启动该程序时从源程序文件中读入。  
- **未初始化数据段（.bss）**：位于这一段中的数据，内核在执行该程序前，将其初始化为0或者null。例如出现在任何函数之外的全局变量：`int sum;`  
- **堆（Heap）**：这个段用于在程序中进行动态内存申请，例如经常用到的 malloc，new 系列函数就是从这个段中申请内存。  
- **栈（Stack）**：函数中的局部变量以及在函数调用过程中产生的临时变量都保存在此段中。  
静态/全局存储区和栈区一般在程序编译阶段决定；而堆区则随着程序的运行而动态变化，每一次程序运行都会有不同的行为，因此动态内存管理对于一个程序在运行过程中占用的内存大小及程序运行性能有非常重要的影响。 本文主要探讨在C++中如何管理动态内存，以及如何使用 C++ 的语言特性来提高动态内存的管理效率，减少错误的发生。
<!-- more -->
## 2. new/delete 操作符
一般来说 C++ 的运行库提供了默认的全局 `new/new[]` 和 `delete/delete[]` 的实现，程序也可以用自定义的实现来取代运行库的实现。 下面是 C++ 标准中定义的 `new/new[]` 和 `delete/delete[]` 的声明（位于 `include/c++/new` 文件中）：

```
namespace std {
  class bad_alloc : public exception {
    public:
      bad_alloc() throw() { }
      virtual ~bad_alloc() throw();
      virtual const char* what() const throw();
  };
  struct nothrow_t { };
  extern const nothrow_t nothrow;
  typedef void (*new_handler)();
  new_handler set_new_handler(new_handler) throw();
} // namespace std

void* operator new(std::size_t) throw (std::bad_alloc);  // (1)
void* operator new[](std::size_t) throw (std::bad_alloc);
void operator delete(void*) throw();
void operator delete[](void*) throw();
void* operator new(std::size_t, const std::nothrow_t&) throw();  // (2)
void* operator new[](std::size_t, const std::nothrow_t&) throw();
void operator delete(void*, const std::nothrow_t&) throw();
void operator delete[](void*, const std::nothrow_t&) throw();
// Default placement versions of operator new.
inline void* operator new(std::size_t, void* __p) throw() { return __p; }  // (3)
inline void* operator new[](std::size_t, void* __p) throw() { return __p; }
// Default placement versions of operator delete.
inline void  operator delete  (void*, void*) throw() { }
inline void  operator delete[](void*, void*) throw() { }
```

其中最后的 `inline` 函数是 `placement` 版本的 new/delete 操作，其特点在于分配的内存块的起始地址由用户给定（通过参数 `void* __p`）。 而前面两种 `new/delete` （(1)和(2)处）是系统决定待分配内存块的起始地址，区别在于：第一个在分配失败是会抛出 `bad_alloc` 异常（这是C++标准要求的）；而第二个则不抛出异常，返回0。 很多应用程序都没有处理内存分配的失败情况，但相对于一个需要长期稳定运行的系统来说，这种处理是必不可少的。 应用程序可以通过捕获 `bad_alloc` 异常或者检查返回值来检查内存分配是否成功，而更好的方法是使用C++中的 `new_handler()` 函数。 C++规定 `new_handler` 要执行如下操作中的一种：

- 使 `new` 有更多的内存可用，然后返回  
- 抛出一个 `bad_alloc` 或其派生类的异常  
- 调用 `abort()` 或者 `exit()` 退出  

下面看一个例子，看看如何使用 `new_handler` 处理内存分配失败的情况：

```
#include<new>
#include<cstdio>
using namespace std;
char *gPool = NULL;
void my_new_handler();

int main(){
    set_new_handler(my_new_handler);
    gPool = new char[100*1024*1024];
    if(gPool!=NULL){
        printf("Preserve 100MB memory at %x.\n",gPool);
    }
    char *p = NULL;
    for(int i=0;i<20;i++){
        p = new char[100*1024*1024];
        printf("%d * 100M, p = %x\n",i+1,p);
    }
    printf("Done.\n");
    return 0;
}

void my_new_handler(){
    if(gPool!=NULL){
        printf("try to get more memory...\n");
        delete[] gPool;
        gPool = NULL;
        return;
    }else{
        printf("I can not help...\n");
        throw bad_alloc();
    }
    return;
}
```

在 Windows 上编译并运行，得到如下输出：

```
Preserve 100MB memory at 980020.
1 * 100M, p = 6d90020
2 * 100M, p = d1a0020
3 * 100M, p = 135b0020
4 * 100M, p = 199c0020
5 * 100M, p = 1fdd0020
6 * 100M, p = 261e0020
7 * 100M, p = 2c5f0020
8 * 100M, p = 32a00020
9 * 100M, p = 38e10020
10 * 100M, p = 3f220020
11 * 100M, p = 45630020
12 * 100M, p = 4ba40020
13 * 100M, p = 51e50020
14 * 100M, p = 58260020
15 * 100M, p = 5e670020
16 * 100M, p = 64a80020
17 * 100M, p = 776c0020
try to get more memory...
18 * 100M, p = 980020
I can not help...
terminate called after throwing an instance of 'std::bad_alloc'
  what():  std::bad_alloc

This application has requested the Runtime to terminate it in an unusual way.
Please contact the application's support team for more information.
```

在 Windows 的 win32 程序中，一个进程可以访问的内存空间是 4GB，但可以用来动态分配的最大内存是 2GB，因而上面的程序执行到第18次（为神马不是第19次？）动态内存分配时由于内存不够，调用了 `my_new_handler` 获得了内存，而当执行第19次内存分配时，`gPool` 已被分配，于是 `my_new_handler` 中抛出了 `bad_alloc` 异常，导致程序退出。

