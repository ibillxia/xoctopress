---
layout: post
title: "C语言函数指针与C++函数调用操作符"
date: 2014-05-24 21:27
comments: true
categories: Program
tags: C语言 C++ 指针 STL
---
## 概述
在编程过程中，一些特殊的时候，我们需要向一个函数传递另一个函数的地址（比如在快速排序中，我们需要传入两个元素大小比较的函数的地址），此时在C语言中一般是通过传递一个函数指针来实现。最近在看《STL源码剖析》一书，上面提到，在C++中其实可以通过另一种方式实现，那就是函数调用操作符`()` 。本文首先介绍一下C语言中函数指针的用法，然后再介绍C++中函数调用操作符的用法。

## C语言中的函数指针
我们先直接看一个例子吧。这个例子比较全面而且简单，其中的函数指针是带参数且有返回值的函数指针，而且还有把函数指针作为参数来传递的代码。这个例子来自 [jobbole伯乐在线](http://blog.jobbole.com/44639/)，代码如下：
<!-- more -->

``` c
#include <stdio.h>
 
// 函数原型
int add(int x, int y);
int subtract(int x, int y);
int domath(int (*mathop)(int, int), int x, int y);
 
// 加法 x+ y
int add(int x, init y) {
    return x + y;
}
 
// 减法 x - y
int subtract(int x, int y) {
    return x - y;
}
 
// 根据输入执行函数指针
int domath(int (*mathop)(int, int), int x, int y) {
    return (*mathop)(x, y);
}

int main() {
	// 用加法调用domath
	int a = domath(add, 10, 2);
	printf("Add gives: %d\n", a);
	 
	// 用减法调用domath
	int b = domath(subtract, 10, 2);
	printf("Subtract gives: %d\n", b);
}
```

在函数 `domath` 中，我们可以根据传入的 `mathop` 函数指针来做不同的计算操作。另外，在该文中，最后提到函数名会被隐式的转换为函数指针，就像作为参数传递的时候，数组名被隐式的转换为指针一样。在函数指针被要求当作输入的任何地方，都能够使用函数名，解引用符 `*` 和取地址符 `&` 用在函数名之前基本上都是多余的。这个之前还真不知道，新技能get，哈哈

#### 使用typedef
在C语言中，对于函数指针，我们可以使用 `typedef` 将其定义为一种数据类型，这样我们就可以定义这种类型的变量了，就像使用普通的变量类型一样。下面是一个具体的定义（来自[stackoverflow](http://stackoverflow.com/questions/4295432/typedef-function-pointer) Jacob的回答）：

        typedef   void      (*FunctionFunc)  ( );
       //         ^                ^         ^
       //     return type      type name  arguments

这里 `typedef` 的使用方法与一般的 `typedef A B` 的使用方式不不大一样的，如果没有接触过这种用法，可能开起来很别扭（在很多开源库中可能经常会碰到）。下面是其具体使用的实例（不完整代码）：

``` c
FunctionFunc x;
void doSomething() { printf("Hello there\n"); }
x = &doSomething;
x(); //prints "Hello there"
```

根据上面提到的隐式转换，这里的取址符其实是没有必要的。关于C语言的函数指针就介绍到这儿了，接下来介绍一下C++的函数调用操作符。

## C++中的函数调用操作符
在C++中，函数调用操作符是指左右小括弧 `()` ，该操作符是可以重载的。许多 STL 算法都提供了两个版本，一个用于一般情况（例如排序时以递增方式排列），一个用于特殊情况（例如排序时按照使用者自定义的大小关系进行排序）。 上面讲了，在C语言中使用者是通过传递函数指针的方式来实现的。然而，函数指针有一些缺点，最重要的是它无法持有自己的状态（这里指局部状态，local states，具体可以通过后面的例子来理解），也无法达到组件技术中的可适配性 —— 也就是无法再将某些修饰条件加诸于其上而改变其状态。

在C++中，对应于C中函数指针的东西是仿函数（functor），使用起来就像函数一样。其实现方法是对某个 class 进行 `operator()` 重载，他就成为一个仿函数。而要成为一个可适配（adaptable）的仿函数，还需要其他的一些努力（在《STL源码剖析》一书的第8章，关于适配器（adaptor）的内容）。这里，我们只拿书中的那个例子来简单的看一下仿函数的定义和使用方法吧。代码如下：

``` cpp
#include <iostream>
using namespace std;

// 对plus进行operator() 重载，使得 plus 变成了一个仿函数
template<class T>
struct plus{
	T operator() (const T &x, const T &y) const {return x+y;}
};

// 对 minus 进行operator() 重载，使得 minus 变成了一个仿函数
template<class T>
struct minus{
	T operator() (const T &x, const T &y) const {return x-y;}
};

int main(){
	// 以下产生仿函数对象
	plus<int> plusObj;
	minus<int> minusObj;
	// 以下使用仿函数，就像使用一般函数一样
	cout<<plusObj(3,5)<<endl;
	cout<<minusObj(3,5)<<endl;
	// 也可以这样使用，通过临时对象（匿名对象）
	cout<<plus<int>()(3,5)<<endl;
	cout<<minus<int>()(3,5)<<endl;
	return 0;
}
```

这里的 `plus<T>` 和 `minus<T>` 已经非常接近 STL 的实现了，唯一的差别是它缺乏“可适配能力”，关于 STL 中的适配器（adaptor），我现在也还没看完该书，也还不太了解，在后续文章中应该会介绍到。读者可以自行google。

## 在快排中使用函数调用操作符
为了加深对函数调用操作符的理解，并将其真正用到实际中，这里拿快排这个非常典型的例子，并充分利用C++及STL的特性。下面是核心代码：

``` cpp
template<typename InIt,typename FuncType>
void myqsort(InIt begin, InIt end, FuncType cmp){
	if(begin==end||begin==end-1)return;
	InIt it = mysplit(begin,end,cmp);
	if(it!=end){
		myqsort(begin,it,cmp);
		myqsort(it+1,end,cmp);
	}
}

template<typename InIt,typename FuncType>
InIt mysplit(InIt begin, InIt end, FuncType cmp){
	InIt itl,itr;
	itl=begin;
	itr=end-1;
	while(itl != itr){
		while(itl != itr && cmp(*itr,*begin)>0)itr--;
		if(itl==itr)break;
		while(itl != itr && cmp(*begin,*itl)>0)itl++;
		if(itl==itr)break;
		swap(*itl,*itr);
		itr--;
	}
	return itl;
}

class Test{
public:
	double m_lf;
	string m_str;
public:
	void set(){ cin>>m_lf>>m_str; }
	void print(){ cout<<m_lf<<" "<<m_str<<endl; }
};

struct cmpd{
	int operator()(Test a,Test b){
		if(abs(a.m_lf - b.m_lf)<INF)return 0;
		if(a.m_lf > b.m_lf)return 1;
		return -1;
	}
};

struct cmps{
	int operator()(Test a,Test b){
		return a.m_str.compare(b.m_str);
	}
};
```

完整的代码及测试输入可以通过以下链接打包下载：[code-2014-05-25](https://ibillxia.github.io/upload/code/20140525.tar.gz)。