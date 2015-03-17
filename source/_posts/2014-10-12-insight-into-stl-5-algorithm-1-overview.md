---
layout: post
title: "深入理解STL源码(5.1) 算法"
date: 2014-10-12 21:30
comments: true
categories: Program
tags: C++ STL 算法
---

## 1. 算法概述  
算法（Algorithm）是一个计算的具体步骤，常用于计算、数据处理和自动推理。Donald Knuth 在他的著作 The Art of Computer Programming 里对算法的特征归纳（来自wiki）：  

- 输入：一个算法必须有零个或以上输入量。  
- 输出：一个算法应有一个或以上输出量，输出量是算法计算的结果。  
- 明确性：算法的描述必须无歧义，以保证算法的实际执行结果是精确地符合要求或期望，通常要求实际运行结果是确定的。  
- 有限性：依据图灵的定义，一个算法是能够被任何图灵完备系统模拟的一串运算，而图灵机只有有限个状态、有限个输入符号和有限个转移函数（指令）。而一些定义更规定算法必须在有限个步骤内完成任务。  
- 有效性：又称可行性。能够实现，算法中描述的操作都是可以通过已经实现的基本运算执行有限次来实现。  

算法的核心是创建问题抽象的模型和明确求解目标，常见的算法有分治法、贪婪算法、动态规划、平摊分析等。再好的编程技巧，也无法让一个笨拙的算法起死回生，选择了错误的算法，便注定了失败的命运。

算法的**时间复杂度**是指算法需要消耗的时间资源。一般来说，计算机算法是问题规模 $n$ 的函数 $f(n)$ ，算法的时间复杂度也因此记做：  
<center> $T(n) = O(f(n))$ </center>  
算法执行时间的增长率与$f(n)$的增长率正相关，称作渐近时间复杂度（Asymptotic Time Complexity），简称时间复杂度。
常见的时间复杂度有：常数阶 $O(1)$ ,对数阶 $O({log}\_ {2}n)$ ,线性阶 $O(n)$ , 线性对数阶 $O(n{log}\_ {2} n)$ ,平方阶 $O(n^2 )$ ，立方阶 $O(n^3 )$ ，...， k次方阶 $O( n^k )$ ,指数阶 $O( 2^n )$ 。随着问题规模 $n$ 的不断增大，上述时间复杂度不断增大，算法的执行效率越低。  

算法的**空间复杂度**是指算法需要消耗的空间资源。其计算和表示方法与时间复杂度类似，一般都用复杂度的渐近性来表示。同时间复杂度相比，空间复杂度的分析要简单得多。
<!-- more -->

## 2. STL 算法概览
很多算法能用来解决特定问题（如排序、查找、复制、比较、组合等），并获得数学上的性能分析与证明，这样的算法非常具有复用性，STL 的算法组件就总结了70+ 个极具复用价值的算法，包括排序（sorting）、查找（searching）、排列组合（permutation）等，以及用于数据移动、复制、删除、比较、组合、运算等算法。  

某些特定的算法与特定的数据结构相关，例如二叉查找树和红黑树便是为了解决查找问题而发展出来的特殊数据结构，hashtable 拥有快速查找能力，又例如 max-heap 可以协助完成 heap sort，几乎可以说，特定的数据结构是为了实现某种特定的算法。这类与特定数据结构相关的算法，在前几篇介绍容器的文章中都有提到，而接下来几篇文章所要介绍的算法则是无特殊条件限制的空间中的某一段元素区间的算法，即泛型算法。

#### 2.1 STL 算法的一般形式   
所有泛型算法的前两个参数都是一对迭代器（iterators），通常称为 first 和 last，用以标识算法的操作区间，STL 习惯采用前闭后开区间表示法，写成 `[first, last)` ，当 `frist==last` 时，表示的是空区间。这个 `[first, last)` 的必要条件是，必须能够进过 increment （累加）操作的反复运用，从 first 到 last，编译器本身无法强求这一点，如果这个条件不成立，会导致无法预料的结果。  

前面讲[迭代器](http://ibillxia.github.io/blog/2014/06/21/stl-source-insight-2-iterators-and-traits/)时我们知道，STL有5类迭代器，他们是input、output、forward、bidirectional、random_access。_每个 STL 算法的声明，都表现出它所需要的最低程度的迭代器类型，例如 `find()` 需要一个 inputIterators 是最低要求，但也可以接受更高类型的，如 forwardIterators、bidirectionalIterators、randomAccessIterators，但如果传给它一个outputIterators，则会导致错误。将无效的迭代器传给某个算法，虽然是一种错误，却不能保证在编译时期就被捕捉出来，因为所谓的迭代器型别并不是真实的型别，他们只是 function template 的一种型别参数（type parameters）。

许多 STL 算法都有很多个版本，除了默认的只包含迭代器参数的实现之外，还有一个可以传入仿函数（functor）参数的版本，例如 `unique()` 缺省情况下使用 `equality` 操作符来比较两个相邻的元素，但如果这些元素的型别并未提供 `equality` 操作符，或如果用户希望定义自己的 `equality` 操作符，便可以传一个仿函数给另一个版本的 `unique()` ，有些算法干脆将这样的两个版本分为两个不同名的实体，如 `find_if()`、`replace_if()` 等。

#### 2.2 质变算法与非质变算法  
所谓**质变算法**（mutating algorithms），是指算法运算过程中，会更改区间`[first, last)`内（迭代器所指）的元素内容，诸如复制（copy）、互换（swap）、替换（replace）、填充（fill）、删除（remove）、排列组合（permutation）、分割（partition）、随机重排（random shuffling）等，都属于此类。通常质变算法提供两个版本，一个是就地（in-place）进行，另一个是copy（另地进行）版本，将操作对象复制一份副本，然后在副本上进行修改并返回该副本。copy版一般以 `_copy` 作为函数名后缀，例如 `replace_copy()` 等。但并不是所有的质变算法都提供copy版，例如 sort 就没有。如果我们一定要使用 copy 版，需要我们自己先 copy 一份副本，然后再将副本传给相应的算法。

所谓**非质变算法**（nonmutating algorithms），是指算法运算过程中不会更改区间`[first, last)`内的元素内容，诸如查找（find）、匹配（search）、计数（count）、巡访（for_each）_、比较（equal，mismatch）、寻找极值（max、min）等。

#### 2.3 STL 算法的分类  
STL 算法的实现主要在 `stl_algobase.h`、`stl_algo.h`、`stl_numeric.h` 这3个文件中，其中 `stl_numeric.h` 主要是数值（numeric）算法，包括 `adjecent_difference()`、`accumulate()`、`inner_product()`、`partial_sum()` 等，相关接口封装在 `<numeric>` 中。而其他算法如复制、填充、交换、求极值、排列、排序、分割等等算法则在剩下的那两个文件中，相关接口则封装在 `<algorithm>` 中。C++ 的 [官方文档](http://www.cplusplus.com/reference/algorithm/) 将 STL 算法分为以下几类：

- Non-modifying sequence operations  非质变操作，查找、计数等  
- Modifying sequence operations  质变操作，复制、交换、替换、填充、删除、逆转、旋转等  
- Partitions 分割
- Sorting 排序
- Binary search (operating on partitioned/sorted ranges) 二分查找
- Merge (operating on sorted ranges) 合并
- Heap、Min/max、Other 堆算法、极值、其他等

后续文章将分别介绍这些算法的具体实现。

## 3. 算法的泛化
上文提到过，很多算法是与底层的数据结构相关的，如何将算法独立于其所处理的数据结构之外，使它能够处理任何数据结构，或者在未知的数据结构（也许是 array，也许是vector，也许是list，也许是deque）上正确地实现操作，并不那么简单。其关键在于，需要把操作对象的型别加以抽象化，把操作对象的标示法和区间目标的移动行为抽象化。如此，整个算法也就在一个抽象层面了，这个过程称为算法的泛型化（generalized），简称泛化。

下面以查找算法的泛化过程为例详细介绍算法泛化的奇妙。对于查找算法，我们首先想到的是在一个整型数组中查找指定元素，一个基本的实现如下：  

``` cpp
int* find(int* arrayHead, int arraySize, int value){
	for(int i=0; i < arraySize; i++){
		if(arrayHead[i] == value) break;
	}
	return &(arrayHead[i]);
}
```

该函数在数组中查找指定值的元素，返回找到的第一个符合条件的元素的地址，如果没有找到就返回最后一个元素的下一个位置（称为end）。当没有找到时，这里为什么要返回地址值（end）而不返回null呢？这是为了方便调用后续的泛型算法，但实际上该算法本身还是与容器相关的，而且暴露了很多容器的实现细节（如arraySize等）。为了让该算法适用于所有类型的容器，其操作应该更抽象化，可以让 find 接受两个指针作为参数，标识出一个操作区间，如下：  

``` cpp
int* find(int* begin, int* end, int value){
	while(begin != end && *begin != value) ++begin;
	return begin;
}
```

该函数在区间 `[begin, end)` 内查找 value，并返回一个指针。这样做之后，已经隐藏了容器内部特性了，但不足的是，要求元素的数据类型为整型，我们可以通过模板参数来解决这个问题：

``` cpp
template<typename T>
T* find(T* begin, T* end, const T& value){
	// 用到了operator !=,*,++
	while(begin != end && *begin != value) ++begin;
	return begin; // 会引发copy行为
}
```

除了参数模板化之外，值得注意的是其中待查找的对象是以常引用的方式传递，这样对于大对象非常有利。于是，现在的find函数几乎适用于任何容器——只要该容器允许指针，而指针又都支持inequality（判断不相等）操作符、dereference（取值）操作符、（prefix）increment（前置式递增）操作符、copy（复制）行为这四种操作。

但这个版本还不够泛化，因为参数被限制为指针，而那些支持以上四种操作、行为很像指针的某些对象就无法使用 find 了。在STL中有迭代器，它是一种行为类似指针的对象，是一种smart pointers，使用迭代器实现 find 如下：

``` cpp
template<class Iterator, class T>
Iterator find(Iterator begin, Iterator end, const T& value){
	while(begin != end && *begin != value) ++begin;
	return begin;
}
```

这便是一个完全泛化的find 函数，它与STL中的find函数几乎一模一样（不同之处可自行查看STL源码）。了解和理解了STL算法的泛化过程，就很容易看懂STL中很多其他的算法了。