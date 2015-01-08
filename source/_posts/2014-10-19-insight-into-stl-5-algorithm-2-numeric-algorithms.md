---
layout: post
title: "深入理解STL源码(5.2) 算法之数值算法"
date: 2014-10-19 20:28
comments: true
categories: Program
tags: C++ STL algorithm numeric
---

本文主要介绍STL中的数值算法，主要涉及到的源码文件有 `stl_numberic.h`、`numeric`、`stl_relops.h` 等。

STL 数值算法主要包含以下几个算法（来自[C++文档](http://www.cplusplus.com/reference/numeric/)）：

- accumulate: Accumulate values in range
- adjacent_difference: Compute adjacent difference of range
- inner_product: Compute cumulative inner product of range
- partial_sum: Compute partial sums of range
- iota: Store increasing sequence
- power: power(x,n) 1 multiply by x n times (not in C++ standard)

下面一一介绍每个算法的实现。

### 1. accumulate

该算法计算 init 和区间 [first, last) 内所有元素的总和。注意，必须提供 init 的初始值，这样即使 first=last 区间为空，仍能得到一个明确定义的值。当 init=0 时，即为计算 [first, last) 区间内所有元素的总和。具体实现有两个版本，如下：

``` cpp
template <class _InputIterator, class _Tp>
_Tp accumulate(_InputIterator __first, _InputIterator __last, _Tp __init){
  __STL_REQUIRES(_InputIterator, _InputIterator); // concept check
  for ( ; __first != __last; ++__first)
    __init = __init + *__first; // 求和
  return __init;
}
template <class _InputIterator, class _Tp, class _BinaryOperation>
_Tp accumulate(_InputIterator __first, _InputIterator __last, _Tp __init, _BinaryOperation __binary_op){
  __STL_REQUIRES(_InputIterator, _InputIterator); // concept check
  for ( ; __first != __last; ++__first)
    __init = __binary_op(__init, *__first); // 指定二元操作
  return __init;
}
```

<!-- more -->
第二个版本通过仿函数参数 _binary_op 指定操作类型，可以实现其他方式的累计，例如累乘等（令init=1，_binary_op=multiply）。

### 2. adjacent_difference
该算法用来计算区间 [first, last) 中相邻元素的差（或其他指定运算，结果[i]=当前元素[i]的值-前驱元素[i-1]的值），该算法也有两个版本，一个是指定运算为差，另一个传入仿函数(参数 _binary_op)指定具体运算，这里贴出第二个版本：

``` cpp
template <class _InputIterator, class _OutputIterator, class _Tp, class _BinaryOperation>
_OutputIterator
__adjacent_difference(_InputIterator __first, _InputIterator __last, 
                      _OutputIterator __result, _Tp*, _BinaryOperation __binary_op) {
  _Tp __value = *__first;
  while (++__first != __last) { // 先 ++ ，再比较
    _Tp __tmp = *__first; // 取第i+1个元素的值
    *++__result = __binary_op(__tmp, __value);
    __value = __tmp; // 保存第i个元素的值
  }
  return ++__result;
}
template <class _InputIterator, class _OutputIterator, class _BinaryOperation>
_OutputIterator adjacent_difference(_InputIterator __first, _InputIterator __last,
                    _OutputIterator __result, _BinaryOperation __binary_op) {
  if (__first == __last) return __result; // 区间为空，直接返回
  *__result = *__first; // 第一个元素没有前驱，直接将当前值赋给结果
  return __adjacent_difference(__first, __last, __result,
                               __VALUE_TYPE(__first), __binary_op);
}
```

### 3. inner_product
该算法实现区间 [first1, last1) 和区间 [first2, first2+(last1-first1) ) 的一般内积（generalized inner product），公式为$init = init+(*i) * (*(first2+(i-first1)))$同样需要提供 init 的值（理由同accumulate）。另外还有一个版本，提供两个仿函数，分别指定上面公式中的加法和乘法。第一个版本的代码如下：
``` cpp
template <class _InputIterator1, class _InputIterator2, class _Tp>
_Tp inner_product(_InputIterator1 __first1, _InputIterator1 __last1,
                  _InputIterator2 __first2, _Tp __init) {
  for ( ; __first1 != __last1; ++__first1, ++__first2)
    __init = __init + (*__first1 * *__first2);
  return __init;
}
```
可以看到，这里其实没有判断第二个区间是否越界，所以在调用时需要我们自己注意，但一般来说计算内积的两个区间都是相同长度的。

### 4. partial_sum
该算法用来计算局部总和，将 `*first` 赋值给 `*result`，将 `*frist+*(first+1)` 赋值给 `*(result+1)`，依次类推，即有 `result[i]=sum(*first..*(first+i))`，这是默认的操作为加法的版本，还有一个版本可以通过仿函数指定操作，以下是默认版本：
``` cpp
template <class _InputIterator, class _OutputIterator, class _Tp>
_OutputIterator __partial_sum(_InputIterator __first, _InputIterator __last,
              _OutputIterator __result, _Tp*) {
  _Tp __value = *__first;
  while (++__first != __last) {
    __value = __value + *__first;
    *++__result = __value; // result 先++，再提领、赋值
  }
  return ++__result;
}
template <class _InputIterator, class _OutputIterator>
_OutputIterator partial_sum(_InputIterator __first, _InputIterator __last,
            _OutputIterator __result){
  if (__first == __last) return __result;
  *__result = *__first; // 第一项直接赋值
  return __partial_sum(__first, __last, __result, __VALUE_TYPE(__first));
}
```
### 5. itoa
该算法不是C++/STL标准，主要作用是将区间 [first, last) 的值赋值为 value,value+1,value+2,... 如下：
``` cpp
template <class _ForwardIter, class _Tp>
void iota(_ForwardIter __first, _ForwardIter __last, _Tp __value){
  while (__first != __last)
    *__first++ = __value++;
}
```

### 6. power
该算法也不是C++/STL标准，作用在于实现 x 的 n 次方的计算，通过将n分解为2的幂来计算。还有一个版本是用户可以指定运算，而不一定是乘法。默认版本如下：
``` cpp
template <class _Tp, class _Integer, class _MonoidOperation>
_Tp __power(_Tp __x, _Integer __n, _MonoidOperation __opr){ // func1：幂方的具体实现
  if (__n == 0)
    return identity_element(__opr);
  else {
    while ((__n & 1) == 0) { // 二进制末尾为0
      __n >>= 1; // n/2
      __x = __opr(__x, __x); // 乘方
    }
    _Tp __result = __x;
    __n >>= 1;
    while (__n != 0) {
      __x = __opr(__x, __x); // 乘方
      if ((__n & 1) != 0) // 二进制末尾为1
        __result = __opr(__result, __x); // 乘入结果
      __n >>= 1;
    }
    return __result;
  }
}
template <class _Tp, class _Integer>
inline _Tp __power(_Tp __x, _Integer __n){ // func2
  return __power(__x, __n, multiplies<_Tp>()); // 调用func3
}
template <class _Tp, class _Integer, class _MonoidOperation>
inline _Tp power(_Tp __x, _Integer __n, _MonoidOperation __opr){ // func3
  return __power(__x, __n, __opr); // 调用func1
}
template <class _Tp, class _Integer>
inline _Tp power(_Tp __x, _Integer __n){
  return __power(__x, __n); // 调用func2
}
```
饶了几道弯，主要看 func1实现即可。