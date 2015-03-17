---
layout: post
title: "深入理解STL源码(5.3) 算法之基本算法algobase"
date: 2014-10-25 21:13
comments: true
categories: Program
tags: C++ STL 算法
---

本文主要介绍STL中的基本算法，主要涉及到的源码文件有 `stl_algobase.h` 等。

在 `stl_algobase.h` 中定义的算法都比较简单基础，主要涉及区间相等判断、区间填充、求极值、交换、拷贝、字典序比较等算法，而其他诸如查找、计数、排序、旋转等算法则在文件 `stl_algo.h` 中实现。在algobase基本算法中，除了字典序比较、复制/拷贝算法外，其他都比较简单，这里先依次介绍这些简单的算法，然后再介绍字典序比较和拷贝算法。

## 1. 交换、填充等简单算法

由于这里很多算法比较简单（基本都在10行以内，甚至很多就一行代码），就不一一粘贴代码了。  

**iter_swap** ：将两个 ForwardIterators 所指的对象对调，通过申请一个临时变量、三次赋值，就完成了。  

**min/max** ：求两个数中的小、大者，还有一个版本可以指定的比较方法（仿函数）。  

**fill** ：将 `[first, last)` 内的所有元素改填为新值 value。  

**fill_n** ：将 `[first, last)` 内的前n个元素改填为新值 value，返回迭代器指向被填入的最后一个元素的下一位置。  

**mismatch** ：用来平行比较两个序列，指出两者之间的第一个不匹配点，返回一对迭代器（Iterators Pair），分别指向两序列中的不匹配点。  

**equal** ：判断两个序列在 `[first, last)` 区间内相等，如果第二个序列元素较多，将不予考虑，只有两个序列在各自区间内对应相等才返回true，否则返回false。
<!-- more -->
## 2. 字典序比较

`lexicographical_compare` 以“字典序排列方式”对两个序列 `[first, last)` 和 `[first2, last2)` 进行比较。比较操作针对两个序列中的对应位置上的元素进行，直到某一对不相等或同时到达尾部或仁义序列到达尾部。该算法其实并不复杂，但有一点值得注意，那就当且仅当第一个序列字典序小于第二个序列时才返回true，以下是各种情况下的返回值：  

- 发现不相等，如果**第一序列元素较小，返回true**，否则返回false；
- 到达last1而尚未到达last2，返回true；
- 到达last2而尚未到达last1，返回false；
- 同时到达last1和last2，返回false。

源码如下：
``` cpp
template <class _InputIter1, class _InputIter2>
bool lexicographical_compare(_InputIter1 __first1, _InputIter1 __last1, _InputIter2 __first2, _InputIter2 __last2) {
  for ( ; __first1 != __last1 && __first2 != __last2; ++__first1, ++__first2) {
    if (*__first1 < *__first2)
      return true;
    if (*__first2 < *__first1)
      return false;
  }
  return __first1 == __last1 && __first2 != __last2;
}
```

除了这个默认的版本外，还有一个版本提供比较方法（仿函数）的参数。另外，对于纯字符串的比较，SGI STL还做了进一步优化，使用原生指针和C标准函数 `memcmp()` 进行比较，如下：

``` cpp
inline bool 
lexicographical_compare(const unsigned char* __first1, const unsigned char* __last1,
                        const unsigned char* __first2,const unsigned char* __last2) {
  const size_t __len1 = __last1 - __first1;
  const size_t __len2 = __last2 - __first2;
  const int __result = memcmp(__first1, __first2, min(__len1, __len2));
  return __result != 0 ? __result < 0 : __len1 < __len2;
}
```

## 3. 复制/拷贝算法

在很多应用程序中，复制copy是一个很常见的操作，特别是在赋值的时候。对于稍微复杂的对象，在不同的语言中赋值时会有一些差别，有的编程语言赋值仅仅是对等号右边的对象的一个引用，而并没有正真的产生一个新的对象，更不用说对象中可能包含的对象成员，例如Python当中的赋值、浅拷贝copy和深拷贝deepcopy等。  

而STL 中的copy，除了简单的单一对象的拷贝之外，还有序列区间的拷贝等，这里就涉及到空间分配和时间效率问题。在C++中，复制操作主要是运用assignment operator（复制运算符） 或 copy constructor（拷贝构造函数），在STL的copy算法中使用的是前者，而对于某些具有trivial assignment operator的数据，则可以使用内存直接复制行为（例如C标准库函数memmove、memcpy等），就能极大的节省时间。SGI STL用尽各种办法，包括函数重载、型别特性、偏特化（partial specialization）等技巧（关于偏特化请参见 [C++模板特化与偏特化](http://www.jellythink.com/archives/410)），无所不用其极地加强效率。

除了上面提到的元素型别、偏特化等问题，还有元素复制顺序的问题。copy 算法是将原始区间 `[first, last)` 内的元素复制到目标区间 `[result, result+last-first)` 区间内，复制时既可以从 first 开始往 last 复制，但也可以从 last-1开始向 first 复制，后者在 STL 另取名为 copy_backward_。从后往前复制的好处在于，不用担心目标区间与原始区间有重叠，因为如果有重叠区域，那么简单的 copy 时，对于原始数据而言 `[result, last)` 区间的数据在被复制前被修改了，从而得不到预期的结果。当然，有一种情况使用 copy 不用担心这个问题，那就是对于迭代器为原生指针，使用 memmove （而不是 memcpy，关于二者的区别参见 [memcpy() vs memmove()](http://stackoverflow.com/questions/4415910/memcpy-vs-memmove)）进行复制，此时 memmove 会先将整个区间复制下来，没有被覆盖的危险。

在介绍 copy 算法的源码具体实现前，根据源码及其注释再做一个简单的小结：copy 算法中的一些辅助函数有两个目的，其一是对于简单的数据类型尽量使用 memmove，其二是对于具有 RandomAccessIterators 的对象使用一个计数器来进行循环；除此之外，SGI STL针对编译器是否具有函数模板偏特化、类模板偏特化等进行了适配。下面是 copy 的源码，其中添加了比较详细具体的注释：

``` cpp
// 首先是几个与偏特化无关的公用的3个函数
template <class _InputIter, class _OutputIter, class _Distance>
inline _OutputIter 
__copy(_InputIter __first, _InputIter __last,
       _OutputIter __result,input_iterator_tag, _Distance*){
  for ( ; __first != __last; ++__result, ++__first) // 使用迭代器遍历和复制
    *__result = *__first;
  return __result;
}
template <class _RandomAccessIter, class _OutputIter, class _Distance>
inline _OutputIter
__copy(_RandomAccessIter __first, _RandomAccessIter __last,
       _OutputIter __result, random_access_iterator_tag, _Distance*){
  for (_Distance __n = __last - __first; __n > 0; --__n) { //对于随机访问迭代器，使用一个计数器n
    *__result = *__first;
    ++__first;
    ++__result;
  }
  return __result;
}
template <class _Tp>
inline _Tp*
__copy_trivial(const _Tp* __first, const _Tp* __last, _Tp* __result) {
  memmove(__result, __first, sizeof(_Tp) * (__last - __first)); // 直接使用 memmove
  return __result + (__last - __first);
}
//============== __STL_FUNCTION_TMPL_PARTIAL_ORDER 对于具有函数模板偏特性的编译器
#if defined(__STL_FUNCTION_TMPL_PARTIAL_ORDER)
template <class _InputIter, class _OutputIter>
inline _OutputIter 
__copy_aux2(_InputIter __first, _InputIter __last, _OutputIter __result, __false_type) { // false_type 的重载版
  return __copy(__first, __last, __result, __ITERATOR_CATEGORY(__first), __DISTANCE_TYPE(__first));
}
template <class _InputIter, class _OutputIter>
inline _OutputIter 
__copy_aux2(_InputIter __first, _InputIter __last, _OutputIter __result, __true_type) { // true_type 的重载版
  return __copy(__first, __last, __result, __ITERATOR_CATEGORY(__first), __DISTANCE_TYPE(__first));
}
#ifndef __USLC__
template <class _Tp>
inline _Tp* 
__copy_aux2(_Tp* __first, _Tp* __last, _Tp* __result, __true_type) { // 原生指针的重载版
  return __copy_trivial(__first, __last, __result);
}
#endif /* __USLC__ */
template <class _Tp>
inline _Tp* 
__copy_aux2(const _Tp* __first, const _Tp* __last, _Tp* __result, __true_type) { // 常量指针的重载版
  return __copy_trivial(__first, __last, __result);
}
template <class _InputIter, class _OutputIter, class _Tp>
inline _OutputIter 
__copy_aux(_InputIter __first, _InputIter __last, _OutputIter __result, _Tp*) {
  typedef typename __type_traits<_Tp>::has_trivial_assignment_operator _Trivial;
  return __copy_aux2(__first, __last, __result, _Trivial());
}
template <class _InputIter, class _OutputIter>
inline _OutputIter 
copy(_InputIter __first, _InputIter __last, _OutputIter __result) { //最终的对外接口
  return __copy_aux(__first, __last, __result, __VALUE_TYPE(__first));
}
//============== __STL_CLASS_PARTIAL_SPECIALIZATION 对于具有类模板偏特性的编译器
#elif defined(__STL_CLASS_PARTIAL_SPECIALIZATION)
template <class _InputIter, class _OutputIter, class _BoolType>
struct __copy_dispatch { // 类1，泛化版
  static _OutputIter copy(_InputIter __first, _InputIter __last, _OutputIter __result) {
    typedef typename iterator_traits<_InputIter>::iterator_category _Category;
    typedef typename iterator_traits<_InputIter>::difference_type _Distance;
    return __copy(__first, __last, __result, _Category(), (_Distance*) 0);
  }
};
template <class _Tp>
struct __copy_dispatch<_Tp*, _Tp*, __true_type>{ // 类2，特化版
  static _Tp* copy(const _Tp* __first, const _Tp* __last, _Tp* __result) {
    return __copy_trivial(__first, __last, __result);
  }
};
template <class _Tp>
struct __copy_dispatch<const _Tp*, _Tp*, __true_type>{ // 类3，特化版
  static _Tp* copy(const _Tp* __first, const _Tp* __last, _Tp* __result) {
    return __copy_trivial(__first, __last, __result);
  }
};
template <class _InputIter, class _OutputIter>
inline _OutputIter 
copy(_InputIter __first, _InputIter __last, _OutputIter __result) { // 对外接口
  typedef typename iterator_traits<_InputIter>::value_type _Tp;
  typedef typename __type_traits<_Tp>::has_trivial_assignment_operator _Trivial;
  return __copy_dispatch<_InputIter, _OutputIter, _Trivial>
    ::copy(__first, __last, __result);
}
//============== 其他，完全不具有偏特化特性的情况
#else /* __STL_CLASS_PARTIAL_SPECIALIZATION */
template <class _InputIter, class _OutputIter>
inline _OutputIter 
copy(_InputIter __first, _InputIter __last, _OutputIter __result){ // 对外接口，泛化版
  return __copy(__first, __last, __result, __ITERATOR_CATEGORY(__first), __DISTANCE_TYPE(__first));
}

#define __SGI_STL_DECLARE_COPY_TRIVIAL(_Tp)                                \
  inline _Tp* copy(const _Tp* __first, const _Tp* __last, _Tp* __result) { \ // 对外接口，特化版
    memmove(__result, __first, sizeof(_Tp) * (__last - __first));          \
    return __result + (__last - __first);                                  \
  }

__SGI_STL_DECLARE_COPY_TRIVIAL(char)
__SGI_STL_DECLARE_COPY_TRIVIAL(signed char)
__SGI_STL_DECLARE_COPY_TRIVIAL(unsigned char)
__SGI_STL_DECLARE_COPY_TRIVIAL(short)
__SGI_STL_DECLARE_COPY_TRIVIAL(unsigned short)
__SGI_STL_DECLARE_COPY_TRIVIAL(int)
__SGI_STL_DECLARE_COPY_TRIVIAL(unsigned int)
__SGI_STL_DECLARE_COPY_TRIVIAL(long)
__SGI_STL_DECLARE_COPY_TRIVIAL(unsigned long)
#ifdef __STL_HAS_WCHAR_T
__SGI_STL_DECLARE_COPY_TRIVIAL(wchar_t)
#endif
#ifdef _STL_LONG_LONG
__SGI_STL_DECLARE_COPY_TRIVIAL(long long)
__SGI_STL_DECLARE_COPY_TRIVIAL(unsigned long long)
#endif
__SGI_STL_DECLARE_COPY_TRIVIAL(float)
__SGI_STL_DECLARE_COPY_TRIVIAL(double)
__SGI_STL_DECLARE_COPY_TRIVIAL(long double)
#undef __SGI_STL_DECLARE_COPY_TRIVIAL
#endif /* __STL_CLASS_PARTIAL_SPECIALIZATION */
```

以上是 copy 的完整代码，关于复制还有两个接口，一个是 `copy_n`，另一个是 `copy_backward`，前者复制区间 `[first, last)` 中前 n 个元素，后者从last-1 往 first 复制，这里就不详细展开了。