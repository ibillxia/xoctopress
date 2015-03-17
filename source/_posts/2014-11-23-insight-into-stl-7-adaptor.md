---
layout: post
title: "深入理解STL源码(7) 配接器adaptor"
date: 2014-11-23 20:21
comments: true
categories: Program
tags: C++ STL 适配器
---

## 1. 概述  
适配器（adaptor/adapter）在STL组件的灵活运用功能上，扮演着轴承、转换器的角色，将一种容器或迭代器装换或封装成另一种容器或迭代器，例如基于deque容器的stack和queue。Adaptor这个概念，实际上是一种设计模式（design pattern），是《Design Pattern》一书中提及到的23个设计模式之一，其中对adaptor的定义如下：

> 将一个class的接口转换为另一个class的接口，使原本因接口不兼容而不能合作的classes，可以一起运作。

在STL中，除了上面提到的容器或迭代器的适配器之外，还可以对函数或更广义的仿函数使用适配器，改变其接口，这种称为function adaptor，相应的针对容器或迭代器的适配器则分别称为container adaptor，iterator adaptor，下面将分别介绍这三种适配器。

## 2. 容器适配器  
容器适配器相对而言比较简单，比较典型的就是上面提到的低层由deque构成的stack和queue，其基本实现原理是，在 stack 和 queue 内部定义一个 protected 的 deque 类型的成员变量，然后只对外提供 deque 的部分功能或其异构，如 stack 的 push 和 pop 都是从 deque 的尾部进行插入和删除，而 queue 的 push 和 pop 分别是从尾部和头部进行插入和删除，这样 stack 和 queue 都可以看做是适配器，作用于容器 deque 之上的适配器。关于 stack 和 queue 的具体内容请参见之前将容器的文章 [深入理解STL源码(3.3) 序列式容器之deque和stack、queue](http://ibillxia.github.io/blog/2014/07/13/stl-source-insight-3-sequential-containers-3-deque-and-stack-queue/)。  

<!-- more -->

## 3. 迭代器适配器  
STL提供了许多作用于迭代器之上的适配器，如 insert iterator，reverse iterator，iostream iterator等，相关源代码主要在 `stl_iterator.h` 文件中。

#### 3.1 insert iterator  
其中 insert iterator 是将一般的迭代器的赋值（assign）操作变为插入（insert）操作，而其他的自增和自减操作则不做任何处理的返回当前迭代器本身，包括从尾部插入的 `back_insert_iterator` 和从头部插入的 `front_insert_iterator` ，尾部插入的 insert iterator 的定义主要内容如下：  

``` cpp
template <class _Container> 
class back_insert_iterator {
public:
  back_insert_iterator<_Container>&
  operator=(const typename _Container::value_type& __value) { // 赋值变为尾部插入
    container->push_back(__value);
    return *this;
  }
  back_insert_iterator<_Container>& operator*() { return *this; } // 一下操作均返回迭代器本身
  back_insert_iterator<_Container>& operator++() { return *this; }
  back_insert_iterator<_Container>& operator++(int) { return *this; }
};
```

#### 3.2 reverse iterator  
reverse iterator 则将一般的迭代器的行进方向逆转，是原本应该前进的 `operator++` 变为后退操作，而 `operator--` 变为前进操作，这样做对于需要从尾部开始遍历的算法非常有用。该迭代器的主要定义如下：  

```
template <class _Iterator>
class reverse_iterator {
protected:
  _Iterator current;
public:
  typedef _Iterator iterator_type;
  typedef reverse_iterator<_Iterator> _Self;
public:
  _Self& operator++() { --current; return *this; } // 前置自增变为自减
  _Self operator++(int) { _Self __tmp = *this; --current; return __tmp; }
  _Self& operator--() { ++current; return *this; } // 前置自减变为自增
  _Self operator--(int) { _Self __tmp = *this; ++current; return __tmp; }
  _Self operator+(difference_type __n) const { return _Self(current - __n); }
  _Self& operator+=(difference_type __n) { current -= __n; return *this; }
  _Self operator-(difference_type __n) const { return _Self(current + __n); }
  _Self& operator-=(difference_type __n) { current += __n; return *this; }
  reference operator[](difference_type __n) const { return *(*this + __n); }  
}; 
```

这种逆向的迭代器只用于那些具有双向迭代器的容器（如vector，list，deque等，而slist，stack，queue，priority queue等则不行）或需要逆向遍历的算法（如copy backward等）。

#### 3.3  iostream iterator  
iostream iterator 则将迭代器绑定到某个 iostream 对象上，有 `istream_iterator` 和 `ostream_iterator` ，分别拥有输入和输出功能。  

以 istream iterator 为例，它将迭代器绑定到一个输入数据流对象（istream object）上，其实就是在 istream iterator 内部维护一个 istream member，用户对这个 istream iterator 所做的 `operator++` 操作会被该迭代器变为这个 istream member 的输入操作 `operator>>`，这个迭代器是一个 input iterator，没有 `operator--` 操作，核心实现如下：

```
template <class _Tp, class _CharT = char, class _Traits = char_traits<_CharT>,
          class _Dist = ptrdiff_t> 
class istream_iterator {
public:
  typedef _CharT                         char_type;
  typedef _Traits                        traits_type;
  typedef basic_istream<_CharT, _Traits> istream_type;
  reference operator*() const { return _M_value; }
  pointer operator->() const { return &(operator*()); }
  istream_iterator& operator++() { _M_read(); return *this; } // ++ 变为 >>
  istream_iterator operator++(int)  { istream_iterator __tmp = *this; _M_read(); return __tmp; }
  bool _M_equal(const istream_iterator& __x) const
    { return (_M_ok == __x._M_ok) && (!_M_ok || _M_stream == __x._M_stream); }
private:
  istream_type* _M_stream;
  _Tp _M_value;
  bool _M_ok;
  void _M_read() {
    _M_ok = (_M_stream && *_M_stream) ? true : false;
    if (_M_ok) {
      *_M_stream >> _M_value; // 转变为输入操作（>>）
      _M_ok = *_M_stream ? true : false;
    }
  }
};
```

可以看到以上的迭代器均非一般意义上的迭代器了，而是一个经过适配了的特殊的迭代器。

## 4. 仿函数适配器  
从上文中我们看到，container adaptor 内含一个container 的成员，iterator 内含一个 iterator 或 iostream 成员，然后对这些成员的标准接口进行了一定的改造，从而使之变成一个新的 container 或 iterator，满足新的应用环境的要求。而仿函数的适配器也是类似的，其实就是在 function adaptor 内部定义了一个成员变量，它是原始 functor 的一个对象，相关源代码主要在 `stl_function.h` 文件中。

STL中标准的 functor adaptor 包括对返回值进行逻辑否定的 `not1`，`not2`；对参数进行绑定的 `bind1st`，`bind2nd`；用于函数合成的 `compose1`，`compose2` （非STL标准，SGI私有）；用于函数指针的 `ptr_fun`；用于成员函数指针的 `mem_fun`，`mem_fun_ref` 等。其中逻辑否定、参数绑定、函数合成的比较简单，如下：

```
// not1其实是对unary_negate函数的一个简单的封装，定义了一个unary_negate类型匿名对象（函数）
inline unary_negate<_Predicate> // 实际效果：!pred(param)
not1(const _Predicate& __pred){ return unary_negate<_Predicate>(__pred);} 
inline binary_negate<_Predicate> // 实际效果：!pred(param1,param2)
not2(const _Predicate& __pred){ return binary_negate<_Predicate>(__pred); }
inline binder1st<_Operation> // 实际效果：op(x,param)
bind1st(const _Operation& __fn, const _Tp& __x) {
  return binder1st<_Operation>(__fn, _Arg1_type(__x));
}
inline binder2nd<_Operation> // 实际效果：op(param,x)
bind2nd(const _Operation& __fn, const _Tp& __x) { 
  return binder2nd<_Operation>(__fn, _Arg2_type(__x));
}
inline unary_compose<_Operation1,_Operation2> // 实际效果：op1(op2(param))
compose1(const _Operation1& __fn1, const _Operation2& __fn2) {
  return unary_compose<_Operation1,_Operation2>(__fn1, __fn2);
}
inline binary_compose<_Operation1, _Operation2, _Operation3> // 实际效果：op1(op2(param),op3(param))
compose2(const _Operation1& __fn1, const _Operation2& __fn2, const _Operation3& __fn3) {
  return binary_compose<_Operation1,_Operation2,_Operation3>
    (__fn1, __fn2, __fn3);
}
```

用于函数指针的 `ptr_fun` 适配器使得我们可以将一般函数当做仿函数使用，就像原生指针可以当做迭代器传给STL算法一样，它的实际效果相当如 `fp(param)` 或 `fp(param1,param2)` ，前者定义如下：

```
template <class _Arg, class _Result>
class pointer_to_unary_function : public unary_function<_Arg, _Result> {
protected:
  _Result (*_M_ptr)(_Arg);
public:
  pointer_to_unary_function() {}
  explicit pointer_to_unary_function(_Result (*__x)(_Arg)) : _M_ptr(__x) {}
  _Result operator()(_Arg __x) const { return _M_ptr(__x); }
};
template <class _Arg, class _Result>
inline pointer_to_unary_function<_Arg, _Result> // 返回值型别
ptr_fun(_Result (*__x)(_Arg)) { // 对pointer_to_unary_function 的封装
  return pointer_to_unary_function<_Arg, _Result>(__x);
}
```

用于成员函数指针的 `mem_fun` 适配器使得我们可以将成员函数当做仿函数使用，于是成员函数可以搭配各种泛型算法，而当使用父类的虚拟成员函数作为仿函数时，还可以使用泛型算法完成所谓的多态调用（polymorphic function call），这是泛型（genericity）与多态（polymorphism）之间的结合。另外需要注意的是，虽然多态可以对指针或引用起作用，但STL容器只支持“实值语意”，不支持“引用语意”，及容器的内容应该为实值而非引用（类似于`vecotr<X&> vc` 这种）。一下是 `mem_fun` 的具体定义（还有很多个版本，这里只是最简单的一个）：

```
// 无任何参数，通过pointer调用，non-const成员函数
template <class _Ret, class _Tp>
class mem_fun_t : public unary_function<_Tp*,_Ret> {
public:
  explicit mem_fun_t(_Ret (_Tp::*__pf)()) : _M_f(__pf) {}
  _Ret operator()(_Tp* __p) const { return (__p->*_M_f)(); }
private:
  _Ret (_Tp::*_M_f)();
};
template <class _Ret, class _Tp>
inline mem_fun_t<_Ret,_Tp> // 返回类型
mem_fun(_Ret (_Tp::*__f)()) { return mem_fun_t<_Ret,_Tp>(__f); } // mem_fun_t的匿名对象
```

## 推荐阅读：  
[Adapter Design Pattern](http://sourcemaking.com/design_patterns/adapter)  
