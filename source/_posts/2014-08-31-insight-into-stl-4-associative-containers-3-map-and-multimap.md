---
layout: post
title: "深入理解STL源码(4.3) 关联式容器之map和multimap"
date: 2014-08-31 21:30
comments: true
categories: Program
tags: C++ STL 容器 map
---

本文涉及到 SGI STL 源码的文件主要是 `stl_map.h`、`stl_multimap.h`、`stl_pair.h`、`map.h`、 `multimap.h`、 `map`  等文件。  

## 1. map 简介  
map 的特性是，所有元素都是键值对，用一个 pair 表示，pair 的第一个元素是键值（key），第二个元素是实值（value），map 不允许两个元素的键值相同。  
与 set 类似的，map 也不允许修改 key 的值，但不同的是可以修改 value 的值，因此 map 的迭代器既不是一种 constant iterators，也不是一种 mutable iterators。同样的，map的插入和删除操作不影响操作之前定义的迭代器的使用（被删除的那个元素除外）。  
与 set 不同的是，map 没有交、并、差等运算，只有插入、删除、查找、比较等基本操作。  
## 2. map 的实现  
由于 map 的元素是键值对，用 pair 表示，下面是它的定义：  
``` cpp
template <class _T1, class _T2>
struct pair {
  typedef _T1 first_type;
  typedef _T2 second_type;
  _T1 first; // 两个成员 first 和 second
  _T2 second;
  pair() : first(_T1()), second(_T2()) {} // 构造函数
  pair(const _T1& __a, const _T2& __b) : first(__a), second(__b) {} // 拷贝构造函数
};
template <class _T1, class _T2>
inline bool operator==(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y) { // 相等比较
  return __x.first == __y.first && __x.second == __y.second; 
}
template <class _T1, class _T2>
inline bool operator<(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y) { // 大小比较
  return __x.first < __y.first || (!(__y.first < __x.first) && __x.second < __y.second); 
}
template <class _T1, class _T2>
inline pair<_T1, _T2> make_pair(const _T1& __x, const _T2& __y) { // 创建一个 pair
  return pair<_T1, _T2>(__x, __y);
}
```  
<!-- more -->
然后是 map 的定义，大体上和 set 差不多，只是在使用 RB-tree 作为容器时，传入的模板参数是一个 pair，主要代码如下：  
``` cpp
template <class _Key, class _Tp, class _Compare, class _Alloc>
class map {
public:
  typedef _Key                  key_type;
  typedef _Tp                   data_type;
  typedef _Tp                   mapped_type;
  typedef pair<const _Key, _Tp> value_type;
  typedef _Compare              key_compare;
  // 一个用于键值比较的内部类
  class value_compare : public binary_function<value_type, value_type, bool> {
  friend class map<_Key,_Tp,_Compare,_Alloc>;
  protected :
    _Compare comp;
    value_compare(_Compare __c) : comp(__c) {}
  public:
    bool operator()(const value_type& __x, const value_type& __y) const {
      return comp(__x.first, __y.first);
    }
  };
private:
  typedef _Rb_tree<key_type, value_type, _Select1st<value_type>, 
    key_compare, _Alloc> _Rep_type; // 这里的value_type是一个pair<const _Key, _Tp>
  _Rep_type _M_t;  // 用红黑树作为底层容器
public:
  map() : _M_t(_Compare(), allocator_type()) {} // 默认构造函数
  bool empty() const { return _M_t.empty(); } // 判断是否为空
  size_type size() const { return _M_t.size(); } // 获取元素个数
  map(const value_type* __first, const value_type* __last)
    : _M_t(_Compare(), allocator_type())
    { _M_t.insert_unique(__first, __last); } // 构造函数，使用insert_unique，键值不允许重复
  void insert(const value_type* __first, const value_type* __last) { // 插入操作
    _M_t.insert_unique(__first, __last);
  }
  void erase(iterator __position) { _M_t.erase(__position); } // 删除操作
  iterator find(const key_type& __x) { return _M_t.find(__x); } // 查找操作
};
```
可以看到，基本也是对底层容器 RB-tree 的一个简单的封装。  
## 3. multimap  
multimap 与 map 的关系和 multiset 与 set 的关系一样，即 multimap 允许键值（key）重复，插入操作使用 RB-tree 的 `insert_equal` ，其他都和 map 一样，这里就不贴源代码了。  
