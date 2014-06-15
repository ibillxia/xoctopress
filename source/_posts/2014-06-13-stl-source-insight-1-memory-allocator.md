---
layout: post
title: "深入理解STL源码(1) 空间配置器(allocator)"
date: 2014-06-13 22:04
comments: true
categories: Program
tags: C++ STL allocator
---
在STL中，Memory Allocator 处于最底层的位置，为一切的 Container 提供存储服务，是一切其他组件的基石。对于一般使用 STL 的用户而言，Allocator 是不可见的，如果需要对 STL 进行扩展，如编写自定义的容器，就需要调用 Allocator 的内存分配函数进行空间配置。  

在C++中，一个对象的内存配置和释放一般都包含两个步骤，对于内存的配置，首先是调用operator new来配置内存，然后调用对象的类的构造函数进行初始化；而对于内存释放，首先是调用析构函数，然后调用 operator delete进行释放。 如以下代码：
```
class Foo { ... };
Foo* pf = new Foo;
...
delete pf;
```
Allocator 的作用相当于operator new 和operator delete的功能，只是它考虑得更加细致周全。SGI STL 中考虑到了内存分配失败的异常处理，内置轻量级内存池（主要用于处理小块内存的分配，应对内存碎片问题）实现， 多线程中的内存分配处理（主要是针对内存池的互斥访问）等，本文就主要分析 SGI STL 中在这三个方面是如何处理的。在介绍着三个方面之前，我们先来看看 Allocator的标准接口。

<!-- more -->

## 1. Allocator 的标准接口
在 SGI STL 中，Allocator的实现主要在文件`alloc.h` 和 `stl_alloc.h` 文件中。根据 STL 规范，Allocator 需提供如下的一些接口（见 `stl_alloc.h` 文件的第588行开始的class template allocator）：  
```
// 标识数据类型的成员变量，关于中间的6个变量的涵义见后续文章（关于Traits编程技巧）
typedef alloc _Alloc;
typedef size_t     size_type;
typedef ptrdiff_t  difference_type;
typedef _Tp*       pointer;
typedef const _Tp* const_pointer;
typedef _Tp&       reference;
typedef const _Tp& const_reference;
typedef _Tp        value_type;
template <class _Tp1> struct rebind {
	typedef allocator<_Tp1> other;
}; // 一个嵌套的class template，仅包含一个成员变量 other
// 成员函数
allocator() __STL_NOTHROW {}  // 默认构造函数，其中__STL_NOTHROW 在 stl_config.h中定义，要么为空，要么为 throw()
allocator(const allocator&) __STL_NOTHROW {}  // 拷贝构造函数
template <class _Tp1> allocator(const allocator<_Tp1>&) __STL_NOTHROW {} // 泛化的拷贝构造函数
~allocator() __STL_NOTHROW {} // 析构函数
pointer address(reference __x) const { return &__x; } // 返回对象的地址
const_pointer address(const_reference __x) const { return &__x; }  // 返回const对象的地址
_Tp* allocate(size_type __n, const void* = 0) {
	return __n != 0 ? static_cast<_Tp*>(_Alloc::allocate(__n * sizeof(_Tp))) : 0; 
	// 配置空间，如果申请的空间块数不为0，那么调用 _Alloc 也即 alloc 的 allocate 函数来分配内存，
} //这里的 alloc 在 SGI STL 中默认使用的是__default_alloc_template<__NODE_ALLOCATOR_THREADS, 0>这个实现（见第402行）
void deallocate(pointer __p, size_type __n) { _Alloc::deallocate(__p, __n * sizeof(_Tp)); } // 释放空间
size_type max_size() const __STL_NOTHROW  // max_size() 函数，返回可成功配置的最大值
    { return size_t(-1) / sizeof(_Tp); }  //这里没看懂，这里的size_t(-1)是什么意思？
void construct(pointer __p, const _Tp& __val) { new(__p) _Tp(__val); } // 调用 new 来给新变量分配空间并赋值
void destroy(pointer __p) { __p->~_Tp(); } // 调用 _Tp 的析构函数来释放空间
```
在SGI STL中设计了如下几个空间分配的 class template：  
```
template <int __inst> class __malloc_alloc_template // Malloc-based allocator.  Typically slower than default alloc
typedef __malloc_alloc_template<0> malloc_alloc
template<class _Tp, class _Alloc> class simple_alloc
template <class _Alloc> class debug_alloc
template <bool threads, int inst> class __default_alloc_template // Default node allocator.
typedef __default_alloc_template<__NODE_ALLOCATOR_THREADS, 0> alloc
typedef __default_alloc_template<false, 0> single_client_alloc
template <class _Tp>class allocator
template<>class allocator<void>
template <class _Tp, class _Alloc>struct __allocator
template <class _Alloc>class __allocator<void, _Alloc>
```
其中`simple_alloc` , `debug_alloc` , `allocator` 和 `__allocator`  的实现都比较简单，都是对其他适配器的一个简单封装（因为实际上还是调用其他配置器的方法，如 `_Alloc::allocate` ）。而真正内容比较充实的是 `__malloc_alloc_template` 和 `__default_alloc_template` 这两个配置器，这两个配置器就是 SGI STL 配置器的精华所在。其中 `__malloc_alloc_template` 是SGI STL 的第一层配置器，只是对系统的 `malloc` , `realloc` 函数的一个简单封装，并考虑到了分配失败后的异常处理。而 `__default_alloc_template` 是SGI STL 的第二层配置器，在第一层配置器的基础上还考虑了内存碎片的问题，通过内置一个轻量级的内存池。下文将先介绍第一级配置器的异常处理机制，然后介绍第二级配置器的内存池实现，及在多线程环境下内存池互斥访问的机制。

## 2. SGI STL 内存分配失败的异常处理
内存分配失败一般是由于out-of-memory(oom)，SGI STL 本身并不会去处理oom问题，而只是提供一个 private 的函数指针成员和一个 public 的设置该函数指针的方法，让用户来自定义异常处理逻辑：
```
private:
#ifndef __STL_STATIC_TEMPLATE_MEMBER_BUG
  static void (* __malloc_alloc_oom_handler)();  // 函数指针
#endif
public:
  static void (* __set_malloc_handler(void (*__f)()))() // 设置函数指针的public方法
  {
    void (* __old)() = __malloc_alloc_oom_handler;
    __malloc_alloc_oom_handler = __f;
    return(__old);
  }
```
如果用户没有调用该方法来设置异常处理函数，那么就不做任何异常处理，仅仅是想标准错误流输出一句out of memory并退出程序（对于使用new和C++特性的情况而言，则是抛出一个`std::bad_alloc()`异常）， 因为该函数指针的缺省值为0，此时对应的异常处理是 `__THROW_BAD_ALLOC`：
```
// line 152 ~ 155
#ifndef __STL_STATIC_TEMPLATE_MEMBER_BUG
template <int __inst>
void (* __malloc_alloc_template<__inst>::__malloc_alloc_oom_handler)() = 0;
#endif
// in _S_oom_malloc and _S_oom_realloc
__my_malloc_handler = __malloc_alloc_oom_handler;
if (0 == __my_malloc_handler) { __THROW_BAD_ALLOC; }
// in preprocess, line 41 ~ 50
#ifndef __THROW_BAD_ALLOC
#  if defined(__STL_NO_BAD_ALLOC) || !defined(__STL_USE_EXCEPTIONS)
#    include <stdio.h>
#    include <stdlib.h>
#    define __THROW_BAD_ALLOC fprintf(stderr, "out of memory\n"); exit(1)
#  else /* Standard conforming out-of-memory handling */
#    include <new>
#    define __THROW_BAD_ALLOC throw std::bad_alloc()
#  endif
#endif
```
SGI STL 内存配置失败的异常处理机制就是这样子了，提供一个默认的处理方法，也留有一个用户自定义处理异常的接口。

## 3. SGI STL 内置轻量级内存池的实现
第一级配置器 `__malloc_alloc_template` 仅仅只是对 `malloc` 的一层封装，没有考虑可能出现的内存碎片化问题。内存碎片化问题在大量申请小块内存是可能非常严重，最终导致碎片化的空闲内存无法充分利用。SGI 于是在第二级配置器 `__default_alloc_template` 中 内置了一个轻量级的内存池。 对于小内存块的申请，从内置的内存池中分配。然后维护一些空闲内存块的链表（简记为空闲链表，free list），小块内存使用完后都回收到空闲链表中，这样如果新来一个小内存块申请，如果对应的空闲链表不为空，就可以从空闲链表中分配空间给用户。具体而言SGI默认最大的小块内存大小为128bytes，并设置了128/8=16 个free list，每个list 分别维护大小为 8, 16, 24, ..., 128bytes 的空间内存块（均为8的整数倍），如果用户申请的空间大小不足8的倍数，则向上取整。

SGI STL内置内存池的实现请看 `__default_alloc_template` 中被定义为 private 的这些成员变量和方法（去掉了部分预处理代码和互斥处理的代码）：
```
private:
#if ! (defined(__SUNPRO_CC) || defined(__GNUC__))
    enum {_ALIGN = 8}; // 对齐大小
    enum {_MAX_BYTES = 128}; // 最大有内置内存池来分配的内存大小
    enum {_NFREELISTS = 16}; // _MAX_BYTES/_ALIGN  // 空闲链表个数
# endif
  static size_t  _S_round_up(size_t __bytes) // 不是8的倍数，向上取整
    { return (((__bytes) + (size_t) _ALIGN-1) & ~((size_t) _ALIGN - 1)); }
__PRIVATE:
  union _Obj { // 空闲链表的每个node的定义
        union _Obj* _M_free_list_link;
        char _M_client_data[1];   };
  static _Obj* __STL_VOLATILE _S_free_list[]; // 空闲链表数组
  static size_t _S_freelist_index(size_t __bytes) { // __bytes 对应的free list的index
        return (((__bytes) + (size_t)_ALIGN-1)/(size_t)_ALIGN - 1);
  }
  static void* _S_refill(size_t __n); // 从内存池中申请空间并构建free list，然后从free list中分配空间给用户
  static char* _S_chunk_alloc(size_t __size, int& __nobjs); // 从内存池中分配空间
  static char* _S_start_free;  // 内存池空闲部分的起始地址
  static char* _S_end_free; // 内存池结束地址
  static size_t _S_heap_size; // 内存池堆大小，主要用于配置内存池的大小
```
其中 `_S_refill` 和 `_S_chunk_alloc` 这两个函数是该内存池机制的核心。 `__default_alloc_template` 对外提供的 public 的接口有 `allocate`, `deallocate` 和 `reallocate` 这三个，其中涉及内存分配的 `allocate` 和 `reallocate` 的逻辑思路是，首先看申请的size（已round up）对应的free list是否为空，如果为空，则调用 `_S_refill` 来分配，否则直接从对应的free list中分配。而 `deallocate` 的逻辑是直接将空间插入到相应free list的最前面。

函数 `_S_refill` 的逻辑是，先调用 `_S_chunk_alloc` 从内存池中分配20块小内存（而不是用户申请的1块），将这20块中的第一块返回给用户，而将剩下的19块依次链接，构建一个free list。这样下次再申请同样大小的内存就不用再从内存池中取了。有了 `_S_refill` ，用户申请空间时，就不是直接从内存池中取了，而是从 free list 中取。因此 `allocate` 和 `reallocate` 在相应的free list为空时都只需直接调用 `_S_refill` 就行了。

这里默认是依次申请20块，但如果内存池空间不足以分配20块时，会尽量分配足够多的块，这些处理都在 `_S_chunk_alloc` 函数中。该函数的处理逻辑如下（源代码这里就不贴了）：
> 1) 能够分配20块  
> > 从内存池分配20块出来，改变 `_S_start_free` 的值，返回分配出来的内存的起始地址  
>
> 2) 不足以分配20块，但至少能分配一块  
> > 分配经量多的块数，改变 `_S_start_free` 的值，返回分配出来的内存的起始地址  
>
> 3) 一块也分配不了
> > 首先计算新内存池大小 `size_t __bytes_to_get = 2 * __total_bytes + _S_round_up(_S_heap_size >> 4)`  
> > 将现在内存池中剩余空间插入到适当的free list中  
> > 调用 `malloc` 来获取一大片空间作为新的内存池：  
-- 如果分配成功，则调整 `_S_end_free` 和 `_S_heap_size` 的值，并重新调用自身，从新的内存池中给用户分配空间； 
-- 否则，分配失败，考虑从比当前申请的空间大的free list中分配空间，如果无法找不到这样的非空free list，则调用第一级配置器的allocate，看oom机制能否解决问题  
>

SGI STL的轻量级内存池的实现就是酱紫了，其实并不复杂。

## 4. SGI STL 内存池在多线程下的互斥访问
最后，我们来看看SGI STL中如何处理多线程下对内存池互斥访问的（实际上是对相应的free list进行互斥访问，这里访问是只需要对free list进行修改的访问操作）。在SGI的第二级配置器中与内存池互斥访问相关的就是 `_Lock` 这个类了，它仅仅只包含一个构造函数和一个析构函数，但这两个函数足够了。在构造函数中对内存池加锁，在析构函数中对内存池解锁：
```
//// in __default_alloc_template
# ifdef __STL_THREADS
    static _STL_mutex_lock _S_node_allocator_lock; // 互斥锁变量
# endif
class _Lock {
    public:
        _Lock() { __NODE_ALLOCATOR_LOCK; }
        ~_Lock() { __NODE_ALLOCATOR_UNLOCK; }
};
//// in preprocess
#ifdef __STL_THREADS
# include <stl_threads.h> // stl 的线程，只是对linux或windows线程的一个封装
# define __NODE_ALLOCATOR_THREADS true
# ifdef __STL_SGI_THREADS
#   define __NODE_ALLOCATOR_LOCK if (threads && __us_rsthread_malloc) \
                { _S_node_allocator_lock._M_acquire_lock(); }  // 获取锁
#   define __NODE_ALLOCATOR_UNLOCK if (threads && __us_rsthread_malloc) \
                { _S_node_allocator_lock._M_release_lock(); }  // 释放锁
# else /* !__STL_SGI_THREADS */
#   define __NODE_ALLOCATOR_LOCK \
        { if (threads) _S_node_allocator_lock._M_acquire_lock(); }
#   define __NODE_ALLOCATOR_UNLOCK \
        { if (threads) _S_node_allocator_lock._M_release_lock(); }
# endif
#else /* !__STL_THREADS */
#   define __NODE_ALLOCATOR_LOCK
#   define __NODE_ALLOCATOR_UNLOCK
#   define __NODE_ALLOCATOR_THREADS false
#endif
```

由于在 `__default_alloc_template` 的对外接口中，只有 `allocate` 和 `deallocate` 中直接涉及到对free list进行修改的操作，所以在这两个函数中，在对free list进行修改之前，都要实例化一个 `_Lock` 的对象 `__lock_instance` ，此时调用构造函数进行加锁，当函数结束时，的对象 `__lock_instance` 自动析构，释放锁。这样，在多线程下，可以保证free list的一致性。