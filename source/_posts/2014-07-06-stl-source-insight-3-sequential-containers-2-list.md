---
layout: post
title: "深入理解STL源码(3.2) 序列式容器之list"
date: 2014-07-06 22:03
comments: true
categories: Program
tags: C++ STL container list
---
本文涉及到 SGI STL 源码的文件有`list`、`stl_list.h`、`list.h` 等几个文件。  

## 1. list 和 slist  
STL中也实现了链表这种数据结构，list是STL标准的双向链表，而slit是SGI的单链表。相比于vector的连续线性空间而言，list即有有点也有缺点：优点是空间分配更灵活，对任何位置的插入删除操作都是常数时间；缺点是排序不方便。list和vector是比较常用的线性容器，那么什么时候用哪一种容器呢，需要视元素的多少、元素构造的复杂度（是否为POD数据）以及元素存取行为的特性而定。限于篇幅，本文主要介绍list的内容，关于单链表slist可以参见源码和侯捷的书。  
## 2. list 的数据结构  
在数据结构中，我们知道链表的节点node和链表list本身是不同的数据结构，以下分别是node和list的数据结构：  
```
struct _List_node_base {
  _List_node_base* _M_next;
  _List_node_base* _M_prev;
};
template <class _Tp>
struct _List_node : public _List_node_base {  // node 的定义
  _Tp _M_data;
};
template <class _Tp, class _Alloc>
class _List_base {
protected:
  _List_node<_Tp>* _M_node; // 只要一个指针就可以表示整个双向链表
};
template <class _Tp, class _Alloc = __STL_DEFAULT_ALLOCATOR(_Tp) >
class list : protected _List_base<_Tp, _Alloc> {
public:
  typedef _List_node<_Tp> _Node;
};
```
<!-- more -->
在list中的 `_M_node` 其实指向一个空白节点，该空白节点的 `_M_data` 成员是没有被初始化的，实际上该节点是链表的尾部，后面将list的迭代器还会提到这样做的好处。  
## 3. list 的配置器  
list缺省使用 alloc （即 `__STL_DEFAULT_ALLOCATOR`） 作为空间配置器，并据此定义了另外一个 `list_node_allocator` ，并定义了`_M_get_node`和`_M_put_node`  两个函数，分别用于分配和释放空间，为的是更方便的以节点大小为配置单位。除此之外，还定义了两个`_M_create_node` 函数，在分配空间的同时调用元素的构建函数对其进行初始化：  
```
template <class _Tp, class _Alloc> 
class _List_base {
protected:
  typedef simple_alloc<_List_node<_Tp>, _Alloc> _Alloc_type; // 专属配置器，每次配置一个节点
  _List_node<_Tp>* _M_get_node() { return _Alloc_type::allocate(1); } // 分配一个节点
  void _M_put_node(_List_node<_Tp>* __p) { _Alloc_type::deallocate(__p, 1); }  // 释放一个节点
};
template <class _Tp, class _Alloc = __STL_DEFAULT_ALLOCATOR(_Tp) > // 缺省使用 __STL_DEFAULT_ALLOCATOR 配置器
class list : protected _List_base<_Tp, _Alloc> { 
protected:
  _Node* _M_create_node(const _Tp& __x){ // 分配空间并初始化
    _Node* __p = _M_get_node();
    __STL_TRY {  _Construct(&__p->_M_data, __x);  }
    __STL_UNWIND(_M_put_node(__p));
    return __p;
  }
  _Node* _M_create_node(){
    _Node* __p = _M_get_node();
    __STL_TRY {  _Construct(&__p->_M_data);  }
    __STL_UNWIND(_M_put_node(__p));
    return __p;
  }
};
```
在list的构造和析构函数、插入、删除等操作中设计到空间的配置。由于list不涉及同时分配多个连续元素的空间，因此用不到SGI的第二层配置器。  
## 4. list 的迭代器  
由于list的节点在内存中不一定连续存储，其迭代器不能像vector那样使用普通指针了，由于list是双向的链表，迭代器必须具备前移、后移的能力，所以它的迭代器是BidirectionalIterators，即双向的可增可减的，以下是list的迭代器的设计：  
```
struct _List_iterator_base {
  typedef bidirectional_iterator_tag iterator_category;
  _List_node_base* _M_node;
  _List_iterator_base(_List_node_base* __x) : _M_node(__x) {}
  _List_iterator_base() {}
  void _M_incr() { _M_node = _M_node->_M_next; }
  void _M_decr() { _M_node = _M_node->_M_prev; }
};
template<class _Tp, class _Ref, class _Ptr>
struct _List_iterator : public _List_iterator_base {
  _Self& operator++() { this->_M_incr(); return *this; }
  _Self operator++(int) { _Self __tmp = *this; this->_M_incr(); return __tmp; }
  _Self& operator--() { this->_M_decr(); return *this; }
  _Self operator--(int) { _Self __tmp = *this; this->_M_decr(); return __tmp; }
};
```
list有一个重要性质，插入操作（insert）和接合操作（splice）都不会造成原有list迭代器失效，而list的删除操作（erase）也只对“指向被删除元素”的那个迭代器失效，其他迭代器不受任何影响。  
## 5. list 的常用操作  
list的常用操作有很多，例如最基本的`push_front`、`push_back`、`pop_front`、`pop_back` 等，这里主要介绍一下`clear`、`remove`、`unique`、`transfer` 这几个。  
**（1）clear**  
clear 函数的作用是清楚整个list的所有节点。  
```
void clear() { _Base::clear(); }
void _List_base<_Tp,_Alloc>::clear() {
  _List_node<_Tp>* __cur = (_List_node<_Tp>*) _M_node->_M_next;
  while (__cur != _M_node) {
    _List_node<_Tp>* __tmp = __cur;
    __cur = (_List_node<_Tp>*) __cur->_M_next; // 后移
    _Destroy(&__tmp->_M_data); // 析构当前节点的对象
    _M_put_node(__tmp); // 释放当前节点的空间
  }
  _M_node->_M_next = _M_node; // 置为空list
  _M_node->_M_prev = _M_node;
}
```
**（2）remove**  
remove 函数的作用是将数值为value的所有元素移除。  
```
void list<_Tp, _Alloc>::remove(const _Tp& __value) {
  iterator __first = begin();
  iterator __last = end();
  while (__first != __last) { // 遍历list
    iterator __next = __first;
    ++__next;
    if (*__first == __value) erase(__first); // 值与 value 相等就移除
    __first = __next;
  }
}
```
**（3）unique**  
unique函数的作用是移除相同的**连续**元素，只有“连续而且相同”的元素，才回被移除到只剩一个。  
```
void list<_Tp, _Alloc>::unique() {
  iterator __first = begin();
  iterator __last = end();
  if (__first == __last) return;
  iterator __next = __first;
  while (++__next != __last) {
    if (*__first == *__next) // 连续连个节点的值相同
      erase(__next);
    else
      __first = __next;
    __next = __first;
  }
}
```
**（4）transfer**  
transfer的作用是将 [first, last) 内的所有元素移动到 position 之前。它是一个私有函数，它为其他常用操作如 splice、sort、merge 等的实现提供了便利。  
```
protected:
  void transfer(iterator __position, iterator __first, iterator __last) {
    if (__position != __last) {
      // Remove [first, last) from its old position.
      __last._M_node->_M_prev->_M_next     = __position._M_node;
      __first._M_node->_M_prev->_M_next    = __last._M_node;
      __position._M_node->_M_prev->_M_next = __first._M_node; 
      // Splice [first, last) into its new position.
      _List_node_base* __tmp      = __position._M_node->_M_prev;
      __position._M_node->_M_prev = __last._M_node->_M_prev;
      __last._M_node->_M_prev     = __first._M_node->_M_prev; 
      __first._M_node->_M_prev    = __tmp;
    }
  }
```
关于list的内容就介绍到这里了。
