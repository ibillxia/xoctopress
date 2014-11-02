---
layout: post
title: "深入理解STL源码(5.4) 算法之复杂算法algorithm"
date: 2014-11-01 10:33
comments: true
categories: Program
tags: C++ STL algorithm sort set heap
---

本文主要介绍STL中的稍微复杂的算法，主要涉及到的源码文件有 `stl_algo.h` 等。

在文件 `stl_algo.h` 中有很多常用的算法，包括查找、计数、旋转、删除、排序、合并、集合的交并等运算、求极值、排列组合等等，本文将按源码中各算法的实现顺序来介绍其具体实现细节。由于本文涉及到的算法和相关代码太多，在文中就尽量不贴出代码了，详细的代码及相关注释请参见 [stl_algo.h](http://ibillxia.github.io/upload/code/stl_algo.h)。

**1. 求三个数的中值 median**  
该算法比较简单，几个if-else语句就解决了。该函数只提供内部算法使用，并不对外提供接口，也不是STL标准中的算法，限于篇幅这里就不贴代码了。另外，该算法有两个版本，一个是使用默认的大小比较，另一个是可以指定比较函数。  

**2. for_each**  
也很简单，就是对区间 [first, last) 中的每一个元素执行一个给定函数的运算，就一行语句：

```
for ( ; __first != __last; ++__first) __f(*__first);
```

其中 `__f` 为用户传入的一个指定的仿函数。该算法的返回值仍为传入的仿函数 `__f` 。

<!--more-->

**3. 查找 find**  
函数 `find` 查找特定值的元素，函数 `find_if` 查找经过用户的指定函数 func（STL中的pred函数） 运算后结果为 true 的元素。主要代码也只有一行：

```
while (__first != __last && !(*__first == __val)) ++__first;
```

另外，关于find，考虑偏特化特性，还有在迭代器为随机存取迭代器时，每次循环进行4次判断和自增，这是所谓的 [loop unrolling](http://en.wikipedia.org/wiki/Loop_unrolling)，在StackOverflow 上也有相关解释 [questions-24295972](http://stackoverflow.com/questions/24295972/)。如果学过体系结构，应该也会提及循环展开的加速方法。

还有一个称为 `adjacent_find` 的查找算法，它查找序列区间中连续相等的两个元素的位置，返回其中第一个元素的迭代器。这个算法就没有做过多的优化和加速考虑了。 

初次之外，在algo文件的最后部分，还有 `find_first_of`、`find_end`、`` 的算法，后面会按顺序介绍到。
  
**4. 计数 count**  
该算法查找序列中值与给定值相等的元素的个数，即进行计数，返回为void，计数结果通过传入的引用参数 `_Size& __n` 来返回给用户，主要代码如下：

```
for ( ; __first != __last; ++__first)
    if (*__first == __value) ++__n;
```

以上这个是非STL标准的，另外还有一个版本返回值为迭代器的 `difference_type` 的偏特化版本，这个才是STL标准。

**5. 搜索search**  
该算法实现的功能是在区间 [first1, last1) 中搜索是否存在与区间 [first2, last2) 中元素都对应相等的子序列，存在则返回区间1中与区间2匹配的起始位置，否则返回last1。基本思路也很简单，详见源码中我的注释。还有一个版本，可以指定判断条件，而不一定是对应相等这个条件。

另外，还有一个 `search_n` 的算法与之相似，只是这个算法搜索区间中是否存在长度为count且值均为val的子序列，存在则返回该子序列的起始位置，否则返回last。同样，它也有一个可以指定判断条件的重载版本。

**6. 区间置换 swap_ranges**  
交换两个长度相等的区间：

```
for ( ; __first1 != __last1; ++__first1, ++__first2)
    iter_swap(__first1, __first2); // 迭代器的交换，使用iter_swap
```

**7. 区间变换运算 transform**  
对区间的每个元素进行opr运算，结果放在result中，仅这一点与 `for_each` 不同：

```
for ( ; __first != __last; ++__first, ++__result)
    *__result = __opr(*__first);
```

还有一个版本是两个等长序列的运算，结果放在result中：

```
for ( ; __first1 != __last1; ++__first1, ++__first2, ++__result)
    *__result = __binary_op(*__first1, *__first2);
```

注意该算法不需要传入第二个区间的last迭代器。

**8. 替换 replace**  
将序列中所有值为oldval的元素值都改为newval：

```
for ( ; __first != __last; ++__first)
   if (*__first == __old_value) *__first = __new_value;
```

另外还有三个版本的替换： `replace_if`，判断条件可以自己指定，而不一定是相等；`replace_copy`，将修改后的结果存到一个新的序列中；`replace_copy_if` 是前两者的合体。

**9.生成 generate**  
将序列中的元素的值按给定函数赋值：

```
for ( ; __first != __last; ++__first) *__first = __gen();
```

还有一个 `generate_n` 将序列中的前n个元素的值按给定函数赋值。

**10.移除 remove**  
移除序列中值为val的元素，与 replace 算法类似，有4个版本，其中 `remove` 和 `remove_if` 分别通过 `remove_copy`、`remove_copy_if` 实现，只需将后者中的result参数设为该序列的起点first。

```
__first = find(__first, __last, __value);
_ForwardIter __i = __first;
return __first == __last ? __first 
                   : remove_copy(++__i, __last, __first, __value);
```

**11.unique和unique_copy**  
将区间的元素的值唯一化，即去掉相邻的重复的项。由于判断时是针对相邻的元素，所以一般需要结合sort使用，如果序列无序需要先对序列排序再进行唯一化。`unique` 的实现是调用 `unique_copy` 来实现的，只是将参数中result仍设为输入序列的first。

这个算法实现的过程中，有很多函数的调用，其中还有个问题没有解决（见代码中注释关于func4什么时候调用func3，func8什么时候调用func7的问题）。

**12.反转 reverse**  
将区间中元素进行反转，一下是迭代器为随机存取迭代器时的实现：

```
while (__first < __last) iter_swap(__first++, --__last);
```

还有迭代器为双向迭代器的版本和非质变算法版本 `reverse_copy`。

**13.旋转 rotate**  
该算法将区间 [first, last) 内的数据以 middle 为分界前后对调，即将[first,middle)+[middle,last) 变为 [middle,last)+[first,middle)。具体实施过程分为两步：首先将middle之后的元素全部调到middle之前，然后对middle之后的元素进行调整，使之按在middle之前时的顺序排列。具体步骤见源码注释，可以结合实例进行理解。该算法的时间复杂度为 $O(n)$，总体上只对序列进行了一次遍历。

另外，除了迭代器为前向迭代器的版本之外，还有迭代器为双向迭代器、随机访问迭代器的版本，分别对算法进行了特化和优化，详见源码注释。其中迭代器为随机访问迭代器时，算法稍微复杂些，但可以通过实例来简化理解。关于旋转算法的几种实现及其效率，可以参见这个 【[Vector Rotation](http://www.cs.bell-labs.com/cm/cs/pearls/s02b.pdf)】，其中三种算法分别对应于STL中的随机迭代器版、前向迭代器版、双向迭代器版。虽然三种算法的复杂度均为线性的，但对于大量数据的旋转，还是会存在一些明显的效率区别的。

**14.随机相关算法 random**  
`random_shuffle` 算法将序列随机重排，具体实现是对序列中每个位置的元素与序列中一个随机的元素进行对调：

```
for (_RandomAccessIter __i = __first + 1; __i != __last; ++__i)
    iter_swap(__i, __first + __random_number((__i - __first) + 1));
```

除了这个版本采用STL的random函数生成随机数的版本外，还有一个版本可以自己指定随机数生成函数。

`random_sample_n` 和 `random_sample` 都是从序列中随机选取n个样本，不同的是输入参数的形式、返回序列的有序性等，均非STL标准。

**15.分割 partition**  
该算法的功能是将序列按条件分割成两个子序列（实际还是一个序列，只是按分割点分成了满足条件的部分和不满足条件的部分），返回分割点的位置。有迭代器为前向迭代器、双向迭代器的版本，保证稳定性的版本 `stable_partition`。

**16. 排序 sort**  
排序算法是STL中最重要也最复杂的算法，总代码量大概是600行（实际上还不止，因为还有调用其他函数，如partition、merge等），占整个文件的1/5。该算法接受两个随机存取迭代器参数，将区间内的元素以渐增的顺序排列，重载版本则允许用户指定一个仿函数作为排序标准。STL的所有关系型容器都拥有自动排序功能（因为底层是RB-tree，属于有序搜索树），不需要用到这个sort算法，而序列式容器中的stack、queue和priority-queue都有特定的出入限制，不允许排序，剩下vector、deque和list、slist，前两者的迭代器都是随机存取迭代器，可以使用sort算法，而list是双向迭代器，slist是前向迭代器，都不适合使用sort算法，如果要对list或slist排序，需要使用list或slist自己实现的sort函数。

`insert_sort` 插入排序：在序列长度较小时（STL中设置的是长度小于16时），使用线性插入排序。

`sort` 快速排序：在序列较长时，将序列分割为一个个小的区间，使得区间整体上有序，然后使用插入排序对整体进行排序。

`stable_sort` 稳定排序：一种思路实际上为归并排序，时间复杂度仍为 $O(nlogn)$，另外还有一种是所谓的merge sort，我表示没看懂%>_<%。

`partial_sort` 使用堆进行排序，但具体原理还没完全弄明白，给跪了。

先看到这儿吧，后面再继续补充，这两天看得实在是要吐了-_-#
