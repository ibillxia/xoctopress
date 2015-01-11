---
layout: post
title: "浅谈C语言的可变参数"
date: 2011-04-21 16:50
comments: true
categories: Program
tags: C语言 栈
---
<h2>1.问题引入</h2>
<p>
C语言中有些函数使用可变参数，比如常见的 `int printf( const char *format [, argument]... );`，
第一个参数format是固定的，其余的参数的个数和类型都不固定。例如：</p>
{% codeblock lang:c %}
printf("Enjoy yourself everyday!/n");
printf("The value is %d!/n", value);
{% endcodeblock %}
<p>这种可变参数可以说是C语言一个比较难理解的部分，这里会由几个问题引发一些对它的分析。
注意：在C++中有函数重载（overload）可以用来区别不同函数参数的调用，但它还是不能表示任意数量的函数参数。</p>

<h2>2.printf（）实现原理</h2>
<p>
C语言用va_start等宏来处理这些可变参数。这些宏看起来很复杂，其实原理挺简单，
就是根据参数入栈的特点从最靠近第一个可变参数的固定参数开始，依次获取每个可变参数的地址。
下面我们来分析这些宏。</p>

<!-- more -->
<p>在`stdarg.h`头文件中，针对不同平台有不同的宏定义，我们选取X86平台下的宏定义：</p>
{% codeblock lang:c %}
typedef char * va_list;
#define _INTSIZEOF(n) ( (sizeof(n) + sizeof(int) - 1) & ~(sizeof(int) - 1) )
#define va_start(ap,v) ( ap = (va_list)&v + _INTSIZEOF(v) )
#define va_arg(ap,t) ( *(t *)((ap += _INTSIZEOF(t)) - _INTSIZEOF(t)) )
#define va_end(ap) ( ap = (va_list)0 )
{% endcodeblock %}
<p>_INTSIZEOF(n)宏是为了考虑那些内存地址需要对齐的系统，从宏的名字来应该是跟sizeof(int)对齐。
一般的`sizeof(int)=4`，也就是参数在内存中的地址都为4的倍数。比如，如果sizeof(n)在1－4之间，
那`_INTSIZEOF(n)＝4`；如果`sizeof(n)`在5－8之间，那么`_INTSIZEOF(n)=8`。</p>

<p>为了能从固定参数依次得到每个可变参数，`va_start`，`va_arg`充分利用下面两点：</br>
&nbsp;&nbsp;&nbsp;&nbsp;1．C语言在函数调用时，先将最后一个参数压入栈;</br>
&nbsp;&nbsp;&nbsp;&nbsp;2．X86平台下的内存分配顺序是从高地址内存到低地址内存</br>
<center>{% img /images/2011/IMAG2011042101.png %}</center></p>

<p>由上图可见，`v`是固定参数在内存中的地址，在调用`va_start`后，`ap`指向第一个可变参数。
这个宏的作用就是在v的内存地址上增加v所占的内存大小，这样就得到了第一个可变参数的地址。</p>

<p>接下来，可以这样设想，如果我能确定这个可变参数的类型，那么我就知道了它占用了多少内存，
依葫芦画瓢，我就能得到下一个可变参数的地址。</p>

<p>让我们再来看看`va_arg`，它先`ap`指向下一个可变参数，然后减去当前可变参数的大小即得到当前
可变参数的内存地址，再做个类型转换，返回它的值。</br>
要确定每个可变参数的类型，有两种做法，要么都是默认的类型，要么就在固定参数中包含足够的
信息让程序可以确定每个可变参数的类型。比如，`printf`，程序通过分析`format`字符串就可以
确定每个可变参数大类型。</br>
最后一个宏就简单了，`va_end`使得`ap`不再指向有效的内存地址。</p>

<p>看了这几个宏，不禁让我再次感慨，C语言太灵活了，而且代码可以写得非常简洁，
虽然有时候让人看得不是很明白，但是一旦明白 过来，你肯定会为它击掌叫好！</br>
其实在`varargs.h`头文件中定义了UNIX System V实行的`va`系列宏，而上面在`stdarg.h`头文件中
定义的是ANSI C形式的宏，这两种宏是不兼容的，一般说来，我们应该使用ANSI C形式的`va`宏。</p>

<h2>3.实战演练</h2>
<p>有没有办法写一个函数，这个函数参数的具体形式可以在运行时才确定？</br>
系统提供了`vprintf`系列格式化字符串的函数，用于编程人员封装自己的I/O函数。</p>
{% codeblock lang:c %}
int vprintf / vscanf(const char * format, va_list ap); // 从标准输入/输出格式化字符串
int vfprintf / vfsacanf(FILE * stream, const char * format, va_list ap);// 从文件流
int vsprintf / vsscanf(char * s, const char * format, va_list ap); // 从字符串
// 例1：格式化到一个文件流，可用于日志文件
FILE *logfile;
int WriteLog(const char * format, ...)
{
   va_list arg_ptr;
   va_start(arg_ptr, format);
   int nWrittenBytes = vfprintf(logfile, format, arg_ptr);
   va_end(arg_ptr);
   return nWrittenBytes;
}
...
// 调用时，与使用printf()没有区别。
WriteLog("%04d-%02d-%02d %02d:%02d:%02d %s/%04d logged out.", nYear, nMonth, nDay, nHour, nMinute, szUserName, nUserID);
{% endcodeblock %}
<p>同理，也可以从文件中执行格式化输入；或者对标准输入输出，字符串执行格式化。</br>
在上面的例1中，`WriteLog()`函数可以接受参数个数可变的输入，本质上，它的实现需要`vprintf()`的支持。
如何真正实现属于自己的可变参数函数，包括控制每一个传入的可选参数。</p>

<h2>4.关于va()函数和va宏</h2>
<p>C语言支持`va`函数，作为C语言的扩展--C++同样支持`va`函数，但在C++中并不推荐使用，C++引入的
多态性同样可以实现参数个数可变的函数。不过，C++的重载功能毕竟只能是有限多个可以预见的参数个数。
比较而言，C中的`va`函数则可以定义无穷多个相当于C++的重载函数，这方面C++是无能为力的。`va`函数的
优势表现在使用的方便性和易用性上，可以使代码更简洁。C编译器为了统一在不同的硬件架构、硬件
平台上的实现，和增加代码的可移植性，提供了一系列宏来屏蔽硬件环境不同带来的差异。</p>

<p>ANSI C标准下，`va`的宏定义在`stdarg.h`中，它们有：`va_list`，`va_start()`，`va_arg()`，`va_end()`。</p>
{% codeblock lang:c %}
// 例2：求任意个自然数的平方和：
int SqSum(int n1, ...)
{
   va_list arg_ptr;
   int nSqSum = 0, n = n1;
   va_start(arg_ptr, n1);
   while (n > 0)
  {
nSqSum += (n * n);
n = va_arg(arg_ptr, int);
  }
  va_end(arg_ptr);
  return nSqSum;
}
// 调用时
int nSqSum = SqSum(7, 2, 7, 11, -1);
{% endcodeblock %}

<p>可变参数函数的原型声明格式为：</p>
{% codeblock lang:c %}
type VAFunction(type arg1, type arg2, ... );
{% endcodeblock %}

<p>参数可以分为两部分：个数确定的固定参数和个数可变的可选参数。函数至少需要一个固定参数，
固定参数的声明和普通函数一样；可选参数由于个数不确定，声明时用"..."表示。固定参数和可选
参数公同构成一个函数的参数列表。借助上面这个简单的例2，来看看各个`va_xxx`的作用。</p>

<p>`va_list arg_ptr`：定义一个指向个数可变的参数列表指针；</br>
`va_start(arg_ptr, argN)`：使参数列表指针`arg_ptr`指向函数参数列表中的第一个可选参数，
说明：`argN`是位于第一个可选参数之前的固定参数，（或者说，最后一个固定参数；...
之前的一个参数），函数参数列表中参数在内存中的顺序与函数声明时的顺序是一致的。
如果有一`va`函数的声明是`void va_test(char a, char b, char c, ...)`，则它的固定
参数依次是a,b,c，最后一个固定参数argN为c，因此就是`va_start(arg_ptr, c)`。</br>
`va_arg(arg_ptr, type)`：返回参数列表中指针`arg_ptr`所指的参数，返回类型为`type`，
并使指针`arg_ptr`指向参数列表中下一个参数。</br>
`va_copy(dest, src)`：`dest`，`src`的类型都是`va_list`，`va_copy()`用于复制参数列表指针，将`dest`初始化为`src`。</br>
`va_end(arg_ptr)`：清空参数列表，并置参数指针`arg_ptr`无效。说明：指针`arg_ptr`被置无效后，
可以通过调用`va_start()`、`va_copy()`恢复`arg_ptr`。每次调用`va_start() / va_copy()`后，
必须得有相应的`va_end()`与之匹配。参数指针可以在参数列表中随意地来回移动，
但必须在`va_start() ... va_end()`之内。</p>

