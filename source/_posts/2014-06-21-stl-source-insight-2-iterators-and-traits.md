---
layout: post
title: "深入理解STL源码(2) 迭代器(Iterators)和Traits"
date: 2014-06-21 21:46
comments: true
categories: Program
tags: C++ STL iterators traits
---
本文涉及到 SGI STL 源码的文件有 `iterator.h`, `stl_iterator_base.h`, `concept_checks.h`, `stl_iterator.h`, `type_traits.h`, `stl_construct.h`, `stl_raw_storage_iter.h` 等7个文件。  

## 1. 迭代器的设计思维
迭代器（iterators）是一种抽象的设计概念，显示程序中并没有直接对应于这个概念的实体。在 *Design Patterns* 一书中，对 iterators 模式的定义如下：提供一种方法，使之能够依序遍历某个聚合物（容器）所包含的各个元素，而又无需暴露该聚合物内部的表述方式。  

在STL中迭代器扮演着重要的角色。STL的中心思想在于：将数据容器（container）和算法（algorithm）分开，彼此独立设计，最后再通过某种方式将他们衔接在一起。容器和算法的泛型化，从技术的角度来看并不困难，C++ 的 class template 和 function template 可以分别达到目标，难点在于如何设计二者之间的衔接器。  

在STL中，起者这种衔接作用的是迭代器，它是一种行为类似指针的对象。指针的各种行为中最常见也最重要的便是内容获取（dereference）和成员访问（member access），因此迭代器最重要的工作就是对 `operator*` 和 `operator->` 进行重载。然而要对这两个操作符进行重载，就需要对容器内部的对象的数据类型和存储结构有所了解，于是在 STL 中迭代器的最终实现都是由容器本身来实现的，每种容器都有自己的迭代器实现，例如我们使用vector容器的迭代器的时候是这样用的 `vector<int>::iterator it;` 。而本文所讨论的迭代器是不依存于特定容器的迭代器，它在STL中主要有以下两个方面的作用（我自己的理解和总结）：  
> - 规定容器中需要实现的迭代器的类型及每种迭代器的标准接口  
> - 通过Traits编程技巧实现迭代器相应型别的获取，弥补 C++ 模板参数推导的不足，为配置器提供可以获取容器中对象型别的接口  

其中前一个没啥好解释的。关于第二个，后面第3节会详细介绍，那就是Traits编程技巧。  

<!-- more -->

## 2. STL 迭代器的分类与标准接口
### 2.1 STL 迭代器的分类  
在SGI STL中迭代器按照移动特性与读写方式分为 `input_iterator`, `output_iterator`, `forward_iterator`, `bidirectional_iterator`, `random_access_iterator` 这5种，他们的定义都在 `stl_iterators_base.h` 文件中。这5种迭代器的特性如下：

- input_iterator:  这种迭代器所指对象只允许读取，而不允许改变，是只读的（read only）。  
- output_iterator:  与上面的相反，只能写（write only）。  
- forward_iterator: 同时允许读和写，适用于 `replace()` 等算法。  
- bidirectional_iterator: 可双向移动，即既可以按顺序访问，也可以按逆序访问。  
- random_access_iterator: 前4种只提供一部分指针运算功能，如前3种只支持 `operator++`, 而第4种还支持 `operator--`, 但这种随机访问迭代器还支持 `p+n`, `p-n`, `p[n]`, `p1-p2`, `p1+p2` 等。  

从以上的特性可以看出，`input_iterator` 和 `output_iterator` 都是特殊的 `forward_iterator`, 而 `forward_iterator` 是特殊的 `bidirectional_iterator`, `bidirectional_iterator` 是特殊的 `random_access_iterator` 。在 `stl_iterator_base.h` 文件中，他们的定义中我们并不能看到这种特性的表达，而只是规定了这几种迭代器类型及应该包含的成员属性，真正表达这些迭代器不同特性的代码在 `stl_iterator.h` 文件中。在 `stl_iterator_base.h` 文件中，除了对这几种迭代器类型进行规定之外，还提供了获取迭代器类型的接口、获取迭代器中的 `value_type` 类型、获取迭代器中的 `distance_type` 、获取两个迭代器的距离（`distance` 函数）、将迭代器向前推进距离 n （`advance` 函数）等标准接口。  

### 2.2 STL迭代器的标准接口  
在 `stl_iterator.h` 文件中，设计了 `back_insert_iterator`, `front_insert_iterator`, `insert_iterator`, `reverse_bidirectional_iterator`, `reverse_iterator`, `istream_iterator`, `ostream_iterator`,  等标准的迭代器，其中前3中都使用 `output_iterator` 的只写特性（只进行插入操作，只是插入的位置不同而已），而第4种使用的是 `bidirectional_iterator` 的双向访问特性，第5种使用的是 `random_access_iterator` 的随机访问特性。而最后两种标准迭代器分别是使用 `input_iterator` 和 `output_iterator` 特性的迭代器。从这几个标准的迭代器的定义中可以看出，主要是实现了 `operator=`, `operator*`, `operator->`, `operator==`, `operator++`, `operator--`, `operator+`, `operator-`, `operator+=`, `operator-=` 等指针操作的标准接口。根据定义的操作符的不同，就是不同类型的迭代器了。  

例如，下面是 `back_insert_iterator` 的标准定义：
``` cpp
template <class _Container>
class back_insert_iterator {
protected:
  _Container* container;
public:
  // member variables
  typedef _Container          container_type;
  typedef output_iterator_tag iterator_category;
  typedef void                value_type;
  typedef void                difference_type;
  typedef void                pointer;
  typedef void                reference;
  // member functions, mainly about operator overloading
  explicit back_insert_iterator(_Container& __x) : container(&__x) {}
  back_insert_iterator<_Container>&
  operator=(const typename _Container::value_type& __value) { 
    container->push_back(__value);
    return *this;
  }
  back_insert_iterator<_Container>& operator*() { return *this; }
  back_insert_iterator<_Container>& operator++() { return *this; }
  back_insert_iterator<_Container>& operator++(int) { return *this; }
};
```

## 3. 迭代器相应型别与Traits编程技巧
### 3.1 迭代器相应型别
在算法中运用迭代器是，很可能需要获取器相应型别，即迭代器所指对象的类型。此时需要使用到 function template 的参数推导（argument deducation）机制，在传入迭代器模板类型的同时，传入迭代器所指对象的模板类型，例如：  
``` cpp
template<class I, class T>
void func_impl(I iter, T t){
    // TODO: Add your code here
}
```
这里不仅要传入类型 `class I`, 还要传入类型 `class T`。然而，迭代器的相应型别并不仅仅只有 “迭代器所指对象的类型” 这一种，例如在STL中就有如下5种：  

- value_type: 迭代器所指对象的类型。  
- difference_type: 表示两个迭代器之间的距离，因此也可以用来表示一个容器的最大容量。例如一个提供计数功能的泛型算法 `count()` ，其返回值的类型就是迭代器的 `difference_type` .   
- reference_type: 从迭代器所指内容是否允许修改来看，迭代器分为 constant iterator 和 mutable iterator，如果传回一个可以修改的对象，一般是以 reference 的方式，因此需要传回引用时，使用此类型。  
- pointer_type: 在需要传回迭代器所指对象的地址时，使用这种类型。  
- iterator_category: 即前面提到5种的迭代器的类型。  

而且实际当中，并不是所有情况都可以通过以上的 template 的参数推导机制来实现（例如算法返回值的类型是迭代器所指对象的类型，template参数推导机制无法推导返回值类型），因此需要更一般化的解决方案，在STL中，这就是Traits编程技巧。  

### 3.2 Traits 编程技巧
在STL的每个标准迭代器中，都定义了5个迭代器相应型别的成员变量，在STL定义了一个统一的接口：  
``` cpp
// In file stl_iterator_base.h
template <class _Category, class _Tp, class _Distance = ptrdiff_t,
          class _Pointer = _Tp*, class _Reference = _Tp&>
struct iterator {
  typedef _Category  iterator_category;
  typedef _Tp        value_type;
  typedef _Distance  difference_type;
  typedef _Pointer   pointer;
  typedef _Reference reference;
};
```
其他的迭代器都可以继承这个标注类，由于后面3个模板参数都有默认值，因此新的迭代器只需提供前两个参数即可（但在SGI STL中并没有使用继承机制）。这样在使用该迭代器的泛型算法中，可以返回这5种类型中的任意一种，而不需要依赖于 template 参数推导的机制。  

在SGI STL中，如果启用 `__STL_CLASS_PARTIAL_SPECIALIZATION` 这个宏定义，还有这样一个标准的 `iterator_traits` ：  
``` cpp
// In file stl_iterator_base.h
template <class _Iterator>
struct iterator_traits {
  typedef typename _Iterator::iterator_category iterator_category;
  typedef typename _Iterator::value_type        value_type;
  typedef typename _Iterator::difference_type   difference_type;
  typedef typename _Iterator::pointer           pointer;
  typedef typename _Iterator::reference         reference;
};
```
值得一提的是，这些类型不仅可以是泛型算法的返回值类型，还可以是传入参数的类型。例如 `iterator_category` 可以作为迭代器的接口 `advance()` 和 `distance()`  的传入参数之一。 不同类型的迭代器实现同一算法的方式可能不同，可以通过这个参数类型来区分不同的重载函数。  

## 4. SGI 中的 __type_traits
traits 编程技巧非常赞，适度弥补了 C++ template 本身的不足。 STL 只对迭代器加以规范，设计了 `iterator_traits` 这样的东西，SGI进一步将这种技法扩展到了迭代器之外，于是有了所谓的 `__type_traits`。

在SGI中， `__type_traits` 可以获取一些类型的特殊属性，如该类型是否具备 trivial default ctor？是否具备 trivial copy ctor？是否具备 trivial assignment operator？是否具备 tivial dtor？是否是 plain old data（POD）？ 如果答案是肯定的，那么我们对这些类型进行构造、析构、拷贝、赋值等操作时，就可以采用比较有效的方法，如不调用该类型的默认构造、析构函数，而是直接调用 `malloc()`, `free()`, `memcpy()` 等等，这对于大量而频繁的操作容器，效率有显著的提升。

SGI中 `__type_traits` 的特性的实现都在 `type_traits.h` 文件中。其中将 `bool`, `char`, `short`, `int`, `long`, `float`, `double` 等基本的数据类型及其相应的指针类型的这些特性都定义为 `__true_type`，这以为着，这些对基本类型进行构造、析构、拷贝、赋值等操作时，都是使用系统函数进行的。而除了这些类型之外的其他类型，除非用户指定了它的这些特性为 `__true_type`，默认都是 `__false_type` 的，不能直接调用系统函数来进行内存配置或赋值等，而需要调用该类型的构造函数、拷贝构造函数等。

另外，用户在自定义类型时，究竟一个 class 什么时候应该是 `__false_type` 的呢？一个简单的判断标准是：如果 class 内部有指针成员并需要对其进行动态配置内存是，这个 class 就需要定义为 `__false_type`的，需要给该类型定义构造函数、拷贝构造函数、析构函数等等。
