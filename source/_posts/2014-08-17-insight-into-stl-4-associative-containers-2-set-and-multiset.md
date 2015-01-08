---
layout: post
title: "深入理解STL源码(4.2) 关联式容器之set和multiset"
date: 2014-08-17 21:30
comments: true
categories: Program
tags: C++ STL container set
---

本文涉及到 SGI STL 源码的文件主要有 `stl_set.h`、 `stl_multiset.h`、 `set.h`、 `multiset.h`、 `set` 等文件。  

## 1. set 简介  
set 即集合，相比于其他容器有些特别。首先是它的每个元素是唯一的，即不允许有相同的值出现。其次，作为一种关联容器，set 的元素不像 map 那样可以同时拥有实值（value）和键值（key），set 元素的键值就是实值，实值就是键值。  
由于 set 的实质和键值相同，共用同一个内存空间，而 set 的底层容器为红黑树（中序遍历有序），因此不能对其键值进行修改，否则会破坏其有序特性。为避免非法修改操作，在SGI STL的实现中，`set<T>::iterator` 被定义为 RB-tree 底层的 const_iterator，_杜绝写入操作。set 与 list 有一个相似的地方是，元素插入、删除后，之前的迭代器依然有效（被删除的那个元素的迭代器除外）。  
我们知道集合有一些特殊的操作，诸如并、交、差等，在STL的 set 中，默认也提供了这些操作，如交集 `set_intersection` 、联集 `set_union` 、差集 `set_difference` 和对称差集 `set_symmetric_difference` 等。与之前那些线性容器不同的是，这些 set 的操作并不是在 set 内部实现的，而是放在了算法模块（algorithm）中，其具体实现在后面的算法章节中会具体介绍。  
## 2. set 的实现  
前面多次提到 set 的底层采用 RB-tree 容器，这是因为 RB-tree 是一种比较高效的平衡二叉搜索树，能够很好的满足元素值唯一的条件，而且查找效率高。由于 RB-tree 已实现了很多操作，因此 set 基本上只是对 RB-tree 进行了一层简单的封装。下面是其实现的主要代码：  
<!-- more -->
``` cpp
template <class _Key, class _Compare, class _Alloc>
class set {
public:
  typedef _Key     key_type;
  typedef _Key     value_type; // 实值与键值同类型
private:
  typedef _Rb_tree<key_type, value_type, _Identity<value_type>, key_compare, _Alloc> _Rep_type;
  _Rep_type _M_t;  // 底层使用红黑树作为容器
  set() : _M_t(_Compare(), allocator_type()) {} // 默认构造函数
  set(const set<_Key,_Compare,_Alloc>& __x) : _M_t(__x._M_t) {}  // 拷贝构造函数
  pair<iterator,bool> insert(const value_type& __x) { // 插入操作
    pair<typename _Rep_type::iterator, bool> __p = _M_t.insert_unique(__x); 
    return pair<iterator, bool>(__p.first, __p.second);
  }
  void erase(iterator __position) { // 删除操作
    typedef typename _Rep_type::iterator _Rep_iterator;
    _M_t.erase((_Rep_iterator&)__position); 
  }
  void clear() { _M_t.clear(); } // 清空操作
  iterator find(const key_type& __x) const { return _M_t.find(__x); } // 查找
  size_type count(const key_type& __x) const { // 计数
    return _M_t.find(__x) == _M_t.end() ? 0 : 1;
  }
};
template <class _Key, class _Compare, class _Alloc>
inline bool operator==(const set<_Key,_Compare,_Alloc>& __x, 
                       const set<_Key,_Compare,_Alloc>& __y) { // 比较相等操作符
  return __x._M_t == __y._M_t;
}
template <class _Key, class _Compare, class _Alloc>
inline bool operator<(const set<_Key,_Compare,_Alloc>& __x, 
                      const set<_Key,_Compare,_Alloc>& __y) { // 比较大小操作符
  return __x._M_t < __y._M_t;
}
```
可以看到基本都是调用 `_M_t` 的方法来实现的，而这里的 `_M_t` 是一个红黑树对象。  
## 3. multiset
multiset 的特性和用法与 set 基本相同，唯一差别在于它允许有重复的键值，因此它的插入操作使用的底层机制是 RB-tree 的 `insert_equal()` 而不是 `insert_unique()` ，下面是 multiset 的主要代码，主要列出了与 set 不同的部分。  
``` cpp
template <class _Key, class _Compare, class _Alloc>
class multiset {
public:
  multiset(const value_type* __first, const value_type* __last)
    : _M_t(_Compare(), allocator_type())
    { _M_t.insert_equal(__first, __last); } // 构造函数
  iterator insert(const value_type& __x) { // 插入操作
    return _M_t.insert_equal(__x);
  }
  iterator insert(iterator __position, const value_type& __x) {
    typedef typename _Rep_type::iterator _Rep_iterator;
    return _M_t.insert_equal((_Rep_iterator&)__position, __x);
  }
  void insert(const value_type* __first, const value_type* __last) {
    _M_t.insert_equal(__first, __last);
  }
  void insert(const_iterator __first, const_iterator __last) {
    _M_t.insert_equal(__first, __last);
  }
};
```
其他部分基本与 set 一样。