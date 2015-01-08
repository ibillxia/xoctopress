---
layout: post
title: "深入理解STL源码(4.4) 关联式容器之hashtable"
date: 2014-09-13 21:30
comments: true
categories: Program
tags: C++ STL container hashtable
---

本文涉及到 SGI STL 源码的文件主要是 `stl_hashtable.h`、`stl_hash_fun.h` 等文件。  

## 1. hashtable 简介  
在数据结构中我们知道，有种数据结构的插入、删除、查找等操作的性能是常数时间，但需要比元素个数更多的空间，这种数据结构就是哈希表。哈希表的基本思想是，将数据存储在与其数值大小相关的地方，比如对该数取模，然后存储在以余数为下表的数组中。但这样会出现一个问题，就是可能会有多个数据被映射到同一个存储位置，即出现了所谓的“碰撞”。哈希表的主要内容就是解决“碰撞”问题，一般而言有以下几种方法：线性探测、二次探测、开链等。  
#### 线性探测  
简单而言，就是在出现“碰撞”后，寻找当前位置以后的空档，然后存入。如果找到尾部都没有空档，则从头部重新开始找。只要空间大小比元素个数大，总能找到的。相应的，元素的查找和删除也与普通的数组不同，查找如果直接定位到相应位置并找到或是空档，就可以确定存在或不存在，而如果定位到当前位置非空且与待查找的元素不同，则要依序寻找后续位置的元素，直到找到或移到了空档。删除则是采用懒惰删除策略，即只标记删除记号，实际删除操作则待表格重新整理时再进行。
#### 二次探测  
与线性探测类似，但向后寻找的策略是探测距当前位置为平方数的位置，即 $index = H+i_^{2}$ _。但这样会有一个问题，那就是能否保证每次探测的是不同的位置，即是否存在某次插入时，探测完一圈后回到自己而出现死循环。
#### 开链  
这种方法是将出现冲突的元素放在一个链表中，而哈希表中只存储这些链表的首地址。SGI STL中就是使用这种方法来解决“碰撞”的。  

## 2. hashtable 的数据结构  
由于使用开链的方法解决冲突，所以要维护两种数据结构，一个是 hash table，在 STL 中称为 buckets，用 vector 作为容器；另一个是链表，这里没有使用 list 或 slist 这些现成的数据结构，而是使用自定义 `__hashtable_node` ，相关定义具体如下：  
<!-- more -->
``` cpp
template <class _Val>
struct _Hashtable_node { // 链表节点的定义
  _Hashtable_node* _M_next; // 指向下一个节点
  _Val _M_val;
}; 
template <class _Val, class _Key, class _HashFcn, class _ExtractKey, class _EqualKey, class _Alloc>
class hashtable {
private:
  typedef _HashFcn hasher;
  hasher                _M_hash; // 哈希函数
  typedef _Hashtable_node<_Val> _Node; // 节点类型别名定义
  vector<_Node*,_Alloc> _M_buckets; // hash table，存储链表的索引
}; 
```
这里 hashtable 的模板参数很多，其含义如下：  
> _Val: 节点的实值类型
> _Key: 节点的键值类型
> _HashFcn: 哈希函数的类型
> _ExtractKey: 从节点中取出键值的方法（函数或仿函数）
> _EqualKey: 判断键值相同与否的方法（函数或仿函数）
> _Alloc: 空间配置器，默认使用 std::alloc

虽然开链法并不要求哈希表的大小为质数，但 SGI STL 仍然以质数来设计表的大小，并将28个质数（大约2倍依次递增）计算好，并提供函数来查询其中最接近某数并大于某数的质数，如下：  
``` cpp
enum { __stl_num_primes = 28 };
static const unsigned long __stl_prime_list[__stl_num_primes] = {
  53ul,         97ul,         193ul,       389ul,       769ul,
  1543ul,       3079ul,       6151ul,      12289ul,     24593ul,
  49157ul,      98317ul,      196613ul,    393241ul,    786433ul,
  1572869ul,    3145739ul,    6291469ul,   12582917ul,  25165843ul,
  50331653ul,   100663319ul,  201326611ul, 402653189ul, 805306457ul, 
  1610612741ul, 3221225473ul, 4294967291ul
}; // 使用无符号长整型（32bit）
inline unsigned long __stl_next_prime(unsigned long __n) {
  const unsigned long* __first = __stl_prime_list;
  const unsigned long* __last = __stl_prime_list + (int)__stl_num_primes;
  const unsigned long* pos = lower_bound(__first, __last, __n); // lower_bound 是泛型算法，后续会介绍
  return pos == __last ? *(__last - 1) : *pos;
}
```
## 3. hashtable 的空间配置  
#### 节点空间配置  
首先只考虑比较简单的情况，即哈希表的大小不需要调整，此时空间配置主要是链表节点的配置，而 hashtable 使用 vector 作为容器，链表节点的空间配置（分配和释放）如下：  
``` cpp
typedef simple_alloc<_Node, _Alloc> _M_node_allocator_type;
_Node* _M_get_node() { return _M_node_allocator_type::allocate(1); } // 分配一个节点的空间
void _M_put_node(_Node* __p) { _M_node_allocator_type::deallocate(__p, 1); } // 释放一个节点的空间
_Node* _M_new_node(const value_type& __obj) {
	_Node* __n = _M_get_node();
	__n->_M_next = 0;
	__STL_TRY {
		construct(&__n->_M_val, __obj);
		return __n;
	}
	__STL_UNWIND(_M_put_node(__n));
}
void _M_delete_node(_Node* __n) {
	destroy(&__n->_M_val);
	_M_put_node(__n);
}
```

#### 插入操作表格重新整理  
哈希表的插入操作有两个问题要考虑，一个是 是否允许插入相同键值的元素，另一个是 是否需要扩充表的大小。在 STL 中，首先是判断新插入一个元素后是否需要扩充，判断的条件是插入后元素的个数大于当前哈希表的大小；而是否允许元素重复则通过提供 `insert_unique` 和 `insert_equal` 来解决。相关代码如下：  
``` cpp
pair<iterator, bool> insert_unique(const value_type& __obj) { 
	resize(_M_num_elements + 1); // 先进行扩充（如有必要）
	return insert_unique_noresize(__obj); // 然后插入
}
iterator insert_equal(const value_type& __obj) {
	resize(_M_num_elements + 1);
	return insert_equal_noresize(__obj);
}
void hashtable<_Val,_Key,_HF,_Ex,_Eq,_All>::resize(size_type __num_elements_hint) { // 扩充表格
  const size_type __old_n = _M_buckets.size();
  if (__num_elements_hint > __old_n) { // 判断是否需要扩充
    const size_type __n = _M_next_size(__num_elements_hint); // 下一个质数
    if (__n > __old_n) {
      vector<_Node*, _All> __tmp(__n, (_Node*)(0), _M_buckets.get_allocator()); // 新的buckets
      __STL_TRY {
        for (size_type __bucket = 0; __bucket < __old_n; ++__bucket) { // 遍历旧的buckets
          _Node* __first = _M_buckets[__bucket];
          while (__first) { // 处理每一个链表
            size_type __new_bucket = _M_bkt_num(__first->_M_val, __n); // 确定当前节点落在新buckets中的位置
            _M_buckets[__bucket] = __first->_M_next; // 指向下一个节点
            __first->_M_next = __tmp[__new_bucket]; // 在新buckets的新索引位置头部插入
            __tmp[__new_bucket] = __first;
            __first = _M_buckets[__bucket]; // 指向旧链表下一个节点
          }
        }
        _M_buckets.swap(__tmp); // 交换新旧buckets，退出后临时buckets __tmp 自动释放
      }
    }
  }
}
template <class _Val, class _Key, class _HF, class _Ex, class _Eq, class _All>
pair<typename hashtable<_Val,_Key,_HF,_Ex,_Eq,_All>::iterator, bool> 
hashtable<_Val,_Key,_HF,_Ex,_Eq,_All>::insert_unique_noresize(const value_type& __obj) { // 不允许键值重复
  const size_type __n = _M_bkt_num(__obj);
  _Node* __first = _M_buckets[__n];
  for (_Node* __cur = __first; __cur; __cur = __cur->_M_next) 
    if (_M_equals(_M_get_key(__cur->_M_val), _M_get_key(__obj))) // 判断是否存在重复的key
      return pair<iterator, bool>(iterator(__cur, this), false); 
  _Node* __tmp = _M_new_node(__obj);
  __tmp->_M_next = __first;
  _M_buckets[__n] = __tmp;
  ++_M_num_elements;
  return pair<iterator, bool>(iterator(__tmp, this), true);
}
```
允许键值重复的插入操作类似的，只是为了确保相同键值的挨在一起，先要找到相同键值的位置，然后插入。  
#### 整体复制和清空  
复制和清空时分别涉及空间的分配和释放，所以在这里也介绍一下。首先是复制操作，需要先将目标 hashtable 清空，然后将源 hashtable 的 buckets 中的每个链表一一复制，如下：  
``` cpp
template <class _Val, class _Key, class _HF, class _Ex, class _Eq, class _All>
void hashtable<_Val,_Key,_HF,_Ex,_Eq,_All>::_M_copy_from(const hashtable& __ht) {
  _M_buckets.clear(); // 先清空目标 hashtable
  _M_buckets.reserve(__ht._M_buckets.size()); // 大小重置为源 hashtable 的大小
  _M_buckets.insert(_M_buckets.end(), __ht._M_buckets.size(), (_Node*) 0); // 将目标 hashtable 的 buckets 置空
  __STL_TRY {
    for (size_type __i = 0; __i < __ht._M_buckets.size(); ++__i) { // 遍历 buckets
      const _Node* __cur = __ht._M_buckets[__i];
      if (__cur) {
        _Node* __copy = _M_new_node(__cur->_M_val);
        _M_buckets[__i] = __copy;
        for (_Node* __next = __cur->_M_next; __next; __cur = __next,
				__next = __cur->_M_next) { // 复制每个节点
          __copy->_M_next = _M_new_node(__next->_M_val);
          __copy = __copy->_M_next;
        }
      }
    }
    _M_num_elements = __ht._M_num_elements;
  }
  __STL_UNWIND(clear());
}
```

## 4. hashtable 的迭代器  
hashtable 的迭代器是前向的单向迭代器，遍历的方式是先遍历完一个 list 然后切换到下一个 bucket 指向的 list 进行遍历。以下是 hashtable 的迭代器的定义：  
``` cpp
template <class _Val, class _Key, class _HashFcn, class _ExtractKey, class _EqualKey, class _Alloc>
struct _Hashtable_iterator {
  typedef hashtable<_Val,_Key,_HashFcn,_ExtractKey,_EqualKey,_Alloc> _Hashtable;
  typedef _Hashtable_iterator<_Val, _Key, _HashFcn, _ExtractKey, _EqualKey, _Alloc> iterator;
  typedef _Hashtable_const_iterator<_Val, _Key, _HashFcn, _ExtractKey, _EqualKey, _Alloc> const_iterator;
  typedef _Hashtable_node<_Val> _Node;

  _Node* _M_cur; // 指向当前节点
  _Hashtable* _M_ht; // 指向当前节点所在 bucket

  _Hashtable_iterator(_Node* __n, _Hashtable* __tab) : _M_cur(__n), _M_ht(__tab) {}
  _Hashtable_iterator() {}
  reference operator*() const { return _M_cur->_M_val; }
  iterator& operator++();
  iterator operator++(int);
  bool operator==(const iterator& __it) const { return _M_cur == __it._M_cur; }
  bool operator!=(const iterator& __it) const { return _M_cur != __it._M_cur; }
};
template <class _Val, class _Key, class _HF, class _ExK, class _EqK, class _All>
_Hashtable_iterator<_Val,_Key,_HF,_ExK,_EqK,_All>&
_Hashtable_iterator<_Val,_Key,_HF,_ExK,_EqK,_All>::operator++(){
  const _Node* __old = _M_cur;
  _M_cur = _M_cur->_M_next;
  if (!_M_cur) { // 到了当前 bucket 的尾部
    size_type __bucket = _M_ht->_M_bkt_num(__old->_M_val);
    while (!_M_cur && ++__bucket < _M_ht->_M_buckets.size())
      _M_cur = _M_ht->_M_buckets[__bucket];
  }
  return *this;
}
```
## 5. 哈希函数  
在第三节中介绍 hashtable 的数据结构时，提到了一个哈希函数类型的模板参数，从键值到索引位置的映射由这个哈希函数来完成，实际中是通过函数 `_M_bkt_num_key` 来完成这个映射的，如下：  
``` cpp
size_type _M_bkt_num_key(const key_type& __key) const {
	return _M_bkt_num_key(__key, _M_buckets.size());
}
size_type _M_bkt_num_key(const key_type& __key, size_t __n) const {
	return _M_hash(__key) % __n; // 在这里调用函数 _M_hash，实现映射
}
```
这里的 `_M_hash` 是一个哈希函数类型的成员，可以看做是一个函数指针，真正的函数的定义在 `<stl_hash_fun.h>` 中，针对 char，int，long 等整数型别，这里大部分的 hash function 什么也没做，只是重视返回原始值，但对字符串（const char* ）设计了一个转换函数，如下：  
``` cpp
template <class _Key> struct hash { }; // 仿函数 hash
inline size_t __stl_hash_string(const char* __s) { // 将字符串映射为整型
  unsigned long __h = 0; 
  for ( ; *__s; ++__s)
    __h = 5*__h + *__s;
  return size_t(__h);
}
__STL_TEMPLATE_NULL struct hash<char*> {
  size_t operator()(const char* __s) const { return __stl_hash_string(__s); } // 函数调用操作符 operator()
};
__STL_TEMPLATE_NULL struct hash<const char*> {
  size_t operator()(const char* __s) const { return __stl_hash_string(__s); }
};
__STL_TEMPLATE_NULL struct hash<char> {
  size_t operator()(char __x) const { return __x; }
};
__STL_TEMPLATE_NULL struct hash<unsigned char> {
  size_t operator()(unsigned char __x) const { return __x; }
};
__STL_TEMPLATE_NULL struct hash<signed char> {
  size_t operator()(unsigned char __x) const { return __x; }
};
__STL_TEMPLATE_NULL struct hash<short> {
  size_t operator()(short __x) const { return __x; }
};
__STL_TEMPLATE_NULL struct hash<unsigned short> {
  size_t operator()(unsigned short __x) const { return __x; }
};
__STL_TEMPLATE_NULL struct hash<int> {
  size_t operator()(int __x) const { return __x; }
};
__STL_TEMPLATE_NULL struct hash<unsigned int> {
  size_t operator()(unsigned int __x) const { return __x; }
};
__STL_TEMPLATE_NULL struct hash<long> {
  size_t operator()(long __x) const { return __x; }
};
__STL_TEMPLATE_NULL struct hash<unsigned long> {
  size_t operator()(unsigned long __x) const { return __x; }
};
```
关于函数调用操作符的更多介绍，可以参见我的另一篇文章 【[C语言函数指针与C++函数调用操作符](http://ibillxia.github.io/blog/2014/05/24/function-pointer-in-c-and-function-call-operator-in-cpp/)】。
