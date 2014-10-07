---
layout: post
title: "深入理解STL源码(4.5) 关联式容器之hashset和hashmap"
date: 2014-09-27 21:30
comments: true
categories: Program
tags: C++ STL container hashset hashmap
---

本文涉及到 SGI STL 源码的文件主要是 `stl_hash_set.h`、`stl_hash_map.h` 等文件。  

## 1. hashset 和 hash_multi_set  
需要说明的是，STL 标准只规范了复杂度与接口，并没有规范实现方法，但 STL 实现的版本中 set 大多以 RB-tree 为底层机制，SGI STL 在实现了以 RB-tree 为底层机制的 set 外，还实现了以 hashtable 为底层机制的 hashset。  
和 set 一样，hashset 的键值（key）和实值（value）是同一个字段，不同的是 set 默认是自动排序的，而 hashset 则是无序的。除此之外，hashset 与 set 的对外接口完全相同。  
这里还有一种称为 hash_multi_set 的集合，它同 multiset 类似，允许键值重复，而上面的 hashset 则不允许。下面是 hashset 的定义的主要代码：  
<!-- more -->
```
template <class _Value, class _HashFcn, class _EqualKey, class _Alloc>
class hash_set {
private:
  typedef hashtable<_Value, _Value, _HashFcn, _Identity<_Value>, _EqualKey, _Alloc> _Ht;
  _Ht _M_ht; // 底层容器的定义
public:
  hash_set() : _M_ht(100, hasher(), key_equal(), allocator_type()) {} // 构造函数
  iterator find(const key_type& __key) const { return _M_ht.find(__key); } // 查找
  size_type count(const key_type& __key) const { return _M_ht.count(__key); } // 计数
  size_type size() const { return _M_ht.size(); } // 表格大小
  size_type max_size() const { return _M_ht.max_size(); } 
  bool empty() const { return _M_ht.empty(); } // 是否为空
  void swap(hash_set& __hs) { _M_ht.swap(__hs._M_ht); } // 交换
  iterator begin() const { return _M_ht.begin(); }
  iterator end() const { return _M_ht.end(); }
  pair<iterator, bool> insert(const value_type& __obj){ // 插入
      pair<typename _Ht::iterator, bool> __p = _M_ht.insert_unique(__obj);
      return pair<iterator,bool>(__p.first, __p.second);
  }
  size_type erase(const key_type& __key) {return _M_ht.erase(__key); } // 擦除
  void erase(iterator __it) { _M_ht.erase(__it); } 
  void erase(iterator __f, iterator __l) { _M_ht.erase(__f, __l); }
  void clear() { _M_ht.clear(); } // 清空
};
template <class _Value, class _HashFcn, class _EqualKey, class _Alloc>
inline bool operator==(const hash_set<_Value,_HashFcn,_EqualKey,_Alloc>& __hs1,
           const hash_set<_Value,_HashFcn,_EqualKey,_Alloc>& __hs2) {
  return __hs1._M_ht == __hs2._M_ht;
}
```

## 2. hashmap 和 hash_multi_map  
hashmap 是以 hashtable 为底层容器的 map，而 map 是同时拥有实值（value）和键值（key），且不允许键值重复。  
而 hash_multi_map 是以 hashtable 为底层容器的 map，且允许键值重复。  

