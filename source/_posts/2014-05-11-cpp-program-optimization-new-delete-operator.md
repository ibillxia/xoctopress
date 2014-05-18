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
#### 2.1 C++内置new/delete的原型
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

#### 2.2 使用 `new_handler` 自定义异常处理
下面看一个例子，看看如何使用 `new_handler` 处理内存分配失败的情况：

```
#include<new>
#include<cstdio>
#include<Windows.h>
using namespace std;
char *gPool = NULL;
void my_new_handler();

int main(){
    set_new_handler(my_new_handler);
    gPool = new char[512*1024*1024];
    if(gPool!=NULL){
        printf("Preserve 512MB memory at %x.\n",gPool);
    }
    char *p = NULL;
    for(int i=0;i<4;i++){
        p = new char[512*1024*1024];
        printf("%d * 512M, p = %x\n",i+1,p);
        Sleep(5000); // 休眠5s
    }
    printf("Done.\n");
    return 0;
}

void my_new_handler(){
    if(gPool!=NULL){
        printf("try to get more memory...\n");
        delete[] gPool; // 释放512MB内存空间
        gPool = NULL;
        return;
    }else{
        printf("I can not help...\n");
        throw bad_alloc();  // 分配失败，抛出异常
    }
    return;
}
```

在 Windows 上编译并运行（使用Code::Blocks 13.12 IDE），得到如下输出：

```
Preserve 512MB memory at 7e0020.
1 * 512M, p = 207f0020
2 * 512M, p = 40800020
try to get more memory...
3 * 512M, p = 7e0020
I can not help...
terminate called after throwing an instance of 'std::bad_alloc'
  what():  std::bad_alloc

This application has requested the Runtime to terminate it in an unusual way.
Please contact the application's support team for more information.
```

在 Windows 的 win32 程序中，一个进程可以访问的内存空间是 4GB，但可以用来动态分配的最大内存是 2GB，因而上面的程序执行到第3次（为神马不是第4次？）动态内存分配时由于内存不够，调用了 `my_new_handler` 获得了内存（可以看到第3次分配的内存的地址和Preserve的内存地址是一样的），而当执行第4次内存分配时，`gPool` 已被分配，于是 `my_new_handler` 中抛出了 `bad_alloc` 异常，导致程序退出。 另外，在程序实际运行过程当中，会发现任务管理器中内存占用不会往上飙，这可能是因为操作系统的动态内存管理策略在作怪，不会说你一申请就立马全部给你，只是建立了一个映射表，只有当你真正用的时候才会给你。

#### 2.3 使用 placement new
在 C++ 内置 `new/delete` 中最后的一种是 placement 形式的 `new/delete` ，即分配的内存地址有用户给定。下面是一个最简单的实例：

```
#include <cstdio>
#include <new>
using namespace std;

int main()
{
    char buffer[100];
    char *p = new(buffer) char[20]; // call placement new
    printf("Address of buffer: %x, and p: %x.\n",buffer,p);
    return 0;
}
// output: Address of buffer: 28feb8, and p: 28feb8.
```

可以看到 `buffer` 和 `p` 的地址是一样的。在大型应用程序中，我们可以充分利用 `placement new` 的特性，实现自己管理（分配、释放等）本应用的内存空间，基本思路就是： 首先申请一大片内存，然后对每个小的动态内存分配都使用 `placement new` 的方式进行申请。

#### 2.4 重载 placement new
在 `new` 操作符中，除了可以使用自定义申请的内存的大小及位置，我们还可以通过重载系统的 `new/delete` 操作符来加入其它一些附加参数，但仍称之为 `placement new` 。例如：

```
#include<cstdio>
#include<new>
using namespace std;
#define DEBUG
#ifdef DEBUG
// 自定义 new 操作符
void *operator new[](unsigned int n, const char* file, int line){
    printf("Alloc size: %d at file %s, in line %d\n",n,file,line);
    return ::operator new(n);
}
// 自定义 delete 操作符
// void operator delete(void *p,const char *file, int line){
void operator delete[](void *p,const char *file, int line){
    printf("delete at file %s, in line %d\n",file,line);
    ::operator delete(p);
    return;
}
// 宏定义，必须放在重载函数之后
#define new new(__FILE__, __LINE__)
#define delete delete(__FILE__, __LINE__)
#endif
int main(){
    char *p = new char[10];
    //delete p;  // delete 的重载还有问题 "error: type 'int' argument given to 'delete', expected pointer"
    delete[] p;  // 直接报语法错误，"error: expected primary-expression before ']' token"
    return 0;
}
// output: Alloc size: 10 at file D:\Programs\test\main.cpp, in line 22
```

这在 `DEBUG` 模式下非常好使。

更新：关于 `placement new` 的 demo 改为如下代码后就没问题了：

```
#include<cstdio>
#include<new>
using namespace std;
#define DEBUG
#ifdef DEBUG
// 自定义 new 操作符
void *operator new[](unsigned int n, const char* file, int line){
    printf("Alloc size: %d at file %s, in line %d\n",n,file,line);
    return ::operator new(n);
}
// 自定义 delete 操作符
void operator delete(void *p,char *file, int line){
    printf("Delete at file %s, in line %d\n",file,line);
    ::operator delete(p);
    return;
}
// 宏定义，必须放在重载函数之后
#define new new(__FILE__, __LINE__)
#define delete(ptr) delete(ptr,__FILE__, __LINE__)
#endif
int main(){
    char *p = new char[10];
    operator delete(p);
    return 0;
}
```

但是还是不知道之前的代码为什么会出现这个错误，已在 [StackOverFlow上提问](http://stackoverflow.com/questions/23614215/destructor-error-in-c-type-int-argument-given-to-delete-expected-pointer)，希望能得到满意的答案。