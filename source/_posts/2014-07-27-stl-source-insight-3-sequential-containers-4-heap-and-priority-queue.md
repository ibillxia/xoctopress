---
layout: post
title: "深入理解STL源码(3.4) 序列式容器之heap和priority queue"
date: 2014-07-27 21:31
comments: true
categories: Program
tags: C++ STL container heap
---
本文涉及到 SGI STL 源码的文件有`heap`、`stl_heap.h`、`heap.h`、`stl_queue.h`、`queue` 等几个文件。  
## 1. 概述  
前面分别介绍了三种各具特色的序列式容器 —— vector、list和deque，他们几乎可以涵盖所有类型的序列式容器了，但本文要介绍的heap则是一种比较特殊的容器。其实，在STL中heap并没有被定义为一个容器，而只是一组算法，提供给priority queue（优先队列）。故名思议，priority queue 允许用户以任何次序将元素放入容器内，但取出时一定是从优先权最高的元素开始取，binary max heap（二元大根堆）即具有这样的特性，因此如果学过max-heap再看STL中heap的算法和priority queue 的实现就会比较简单。  
## 2. priority queue 的数据结构   
要实现priority queue的功能，binary search tree（BST）也可以作为其底层机制，但这样的话元素的插入就需要O(logN)的平均复杂度，而且要求元素的大小比较随机，才能使树比较平衡。而binary heap是一种完全二叉树的结构，而且可以使用vector来存储：  
```
template <class _Tp, class _Sequence __STL_DEPENDENT_DEFAULT_TMPL(vector<_Tp>), class _Compare __STL_DEPENDENT_DEFAULT_TMPL(less<typename _Sequence::value_type>) >
class priority_queue { // in stl_queue.h 文件中
protected:
  _Sequence c; // 使用vector作为数据存储的容器
  _Compare comp;
};
```
另外只需要提供一组heap算法，即元素插入和删除、获取堆顶元素等操作即可。  
<!-- more -->
## 3. push heap 算法  
为了满足完全二叉树的特性，新加入的元素一定要放在vector的最后面；又为了满足max-heap的条件（每个节点的键值不小于其叶子节点的键值），还需要执行上溯过程，将新插入的元素与其父节点进行比较，直到不大于父节点：  
```
template <class _RandomAccessIterator, class _Distance, class _Tp>
void __push_heap(_RandomAccessIterator __first, _Distance __holeIndex, _Distance __topIndex, _Tp __value){
  _Distance __parent = (__holeIndex - 1) / 2; //  新节点的父节点
  while (__holeIndex > __topIndex && *(__first + __parent) < __value) { // 插入时的堆调整过程：当尚未到达顶端且父节点小于新值时，需要将新值往上（前）调整
    *(__first + __holeIndex) = *(__first + __parent); // 父节点下移
    __holeIndex = __parent;
    __parent = (__holeIndex - 1) / 2;
  }    
  *(__first + __holeIndex) = __value; // 找到新值应当存储的位置
}
template <class _RandomAccessIterator, class _Distance, class _Tp>
inline void __push_heap_aux(_RandomAccessIterator __first, _RandomAccessIterator __last, _Distance*, _Tp*) {
  __push_heap(__first, _Distance((__last - __first) - 1), _Distance(0), _Tp(*(__last - 1))); 
}
template <class _RandomAccessIterator>
inline void push_heap(_RandomAccessIterator __first, _RandomAccessIterator __last) { // 真正的对外接口，在调用之前，元素已经放在了vector的最后面了（见priority queue的push_back）
  __STL_REQUIRES(_RandomAccessIterator, _Mutable_RandomAccessIterator);
  __STL_REQUIRES(typename iterator_traits<_RandomAccessIterator>::value_type, _LessThanComparable);
  __push_heap_aux(__first, __last, __DISTANCE_TYPE(__first), __VALUE_TYPE(__first)); // 直接调用 __push_heap_aux
}
```
## 4. pop heap 算法  
对heap进行pop操作就是取顶部的元素，取走后要对heap进行调整，是之满足max-heap的特性。调整的策略是，首先将最末尾的元素放到堆顶，然后进行下溯操作，将对顶元素下移到适当的位置：  
```
template <class _RandomAccessIterator, class _Distance, class _Tp>
void __adjust_heap(_RandomAccessIterator __first, _Distance __holeIndex, _Distance __len, _Tp __value) { // 调整堆
  _Distance __topIndex = __holeIndex; // 堆顶
  _Distance __secondChild = 2 * __holeIndex + 2;
  while (__secondChild < __len) {
    if (*(__first + __secondChild) < *(__first + (__secondChild - 1))) __secondChild--; // secondChild 为左右两个子节点中较大者
    *(__first + __holeIndex) = *(__first + __secondChild); // 节点的值上移
    __holeIndex = __secondChild;
    __secondChild = 2 * (__secondChild + 1); // 下移一层
  }
  if (__secondChild == __len) { // 最后一个元素
    *(__first + __holeIndex) = *(__first + (__secondChild - 1));
    __holeIndex = __secondChild - 1;
  }
  __push_heap(__first, __holeIndex, __topIndex, __value);
}
template <class _RandomAccessIterator, class _Tp, class _Distance>
inline void __pop_heap(_RandomAccessIterator __first, _RandomAccessIterator __last, _RandomAccessIterator __result, _Tp __value, _Distance*) {
  *__result = *__first; // 获取堆顶元素，并赋给堆尾的last-1
  __adjust_heap(__first, _Distance(0), _Distance(__last - __first), __value); // 调整堆
}
template <class _RandomAccessIterator, class _Tp>
inline void __pop_heap_aux(_RandomAccessIterator __first, _RandomAccessIterator __last, _Tp*) {
  __pop_heap(__first, __last - 1, __last - 1, _Tp(*(__last - 1)), __DISTANCE_TYPE(__first)); // 对 [first,last-1)进行pop，并将first赋给last-1
}
template <class _RandomAccessIterator>
inline void pop_heap(_RandomAccessIterator __first, _RandomAccessIterator __last) { // 对外提供的接口，最后堆顶元素在堆的末尾，而[first,last-1) 区间为新堆，该接口调用完后再进行pop操作移除最后的元素
  __STL_REQUIRES(_RandomAccessIterator, _Mutable_RandomAccessIterator);
  __STL_REQUIRES(typename iterator_traits<_RandomAccessIterator>::value_type, _LessThanComparable);
  __pop_heap_aux(__first, __last, __VALUE_TYPE(__first));
}
```
## 5. make heap 算法  
最后，我们来看看如何从一个初始序列来创建一个heap，有了前面的 `adjust_heap` ，创建heap也就很简单了，只需要从最后一个非叶子节点开始，不断调用堆调整函数，即可使得整个序列称为一个heap：  
```
template <class _RandomAccessIterator, class _Compare, class _Tp, class _Distance>
void __make_heap(_RandomAccessIterator __first, _RandomAccessIterator __last, _Compare __comp, _Tp*, _Distance*) {
  if (__last - __first < 2) return;
  _Distance __len = __last - __first;
  _Distance __parent = (__len - 2)/2; // 定位到最后一个非叶子节点
  while (true) { // 对每个非叶子节点为根的子树进行堆调整
    __adjust_heap(__first, __parent, __len, _Tp(*(__first + __parent)), __comp);
    if (__parent == 0) return;
    __parent--;
  }
}
template <class _RandomAccessIterator, class _Compare>
inline void make_heap(_RandomAccessIterator __first, _RandomAccessIterator __last, _Compare __comp) { // 对外提供的接口
  __STL_REQUIRES(_RandomAccessIterator, _Mutable_RandomAccessIterator);
  __make_heap(__first, __last, __comp, __VALUE_TYPE(__first), __DISTANCE_TYPE(__first));
}
```
## 6. 基于 heap 的 priority queue  
上一篇文章中讲到stack和queue都是基于deque实现的，这里的priority queue是基于vector和heap来实现的，默认使用vector作为容器，而使用heap的算法来维持其priority的特性，因此priority queue也被归类为container adapter。其具体实现的主要代码如下:  
```
template <class _Tp, class _Sequence __STL_DEPENDENT_DEFAULT_TMPL(vector<_Tp>), class _Compare __STL_DEPENDENT_DEFAULT_TMPL(less<typename _Sequence::value_type>) >
class priority_queue {
protected:
  _Sequence c;
  _Compare comp;
public:
  priority_queue() : c() {}
  explicit priority_queue(const _Compare& __x) :  c(), comp(__x) {}
  priority_queue(const _Compare& __x, const _Sequence& __s) : c(__s), comp(__x) 
    { make_heap(c.begin(), c.end(), comp); }
  bool empty() const { return c.empty(); }
  size_type size() const { return c.size(); }
  const_reference top() const { return c.front(); }
  void push(const value_type& __x) {
    __STL_TRY {
      c.push_back(__x); // 在push_heap之前先将x放在vector c的最后面
      push_heap(c.begin(), c.end(), comp);
    }
    __STL_UNWIND(c.clear());
  }
  void pop() {
    __STL_TRY {
      pop_heap(c.begin(), c.end(), comp);
      c.pop_back(); // 在调用pop_heap之后才将最后一个元素剔除出vector c
    }
    __STL_UNWIND(c.clear());
  }
};
```
值得一提的是，priority queue也没有迭代器，不能对其进行遍历等操作，因为它只能在顶部取和删除元素，而插入元素的位置也是确定的，而不能有用户指定。  
关于heap和priority queue的内容就介绍到这里了，而序列式容器的介绍也到此结束了。