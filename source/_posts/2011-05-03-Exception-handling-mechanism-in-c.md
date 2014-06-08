---
layout: post
title: "C语言中的异常处理机制"
date: 2011-05-03 11:09
comments: true
categories: Program
tags: C Exception goto setjmp longjmp
---
<h2>1.概述</h2>
<p>什么是异常？异常一般指的是程序运行期（Run-Time）发生的非正常情况。异常一般是不可预测的，如：内存不足、打开文件失败、
范围溢出等。UNIX 使用信号给出异常，并当发生异常时转跳到信号处理过程进行异常处理。DOS下的信号对比UNIX系统而言相对较少。</p>


<p>我们知道，不管是在c++还是在java中，异常都被认为是一种很优雅的处理错误的机制。而如果想在c语言中使用异常就比较麻烦，
但是我们仍然可以使用c语言中强大的setjmp和longjmp函数实现类似于c++的异常处理机制。</p>

<p>异常处理的核心思想是，把功能模块代码与系统中可能出现错误的处理代码分离开来，以此来达到使我们的代码组织起来更美观、
逻辑上更清晰，并且同时从根本上来提高我们软件系统长时间稳定运行的可靠性。那么，现在回过头来看，实际上在计算机系统的硬件
设计中，操作系统的总体设计中，早期的许多面向结构化程序设计语言中(例如C语言)，都有异常处理的机制和方法的广泛运用。</p>

<h2>2.基于goto语句的异常处理</h2>
<p>goto语句，程序员朋友们对它太熟悉了，它是C语言中使用最为灵活的一条语句，由它也充分体现出了C语言的许多特点或者说是优点。
它虽然是一条高级语言中提供的语句，但是它一般却直接对应一条“无条件直接跳转的机器指令”，所以说它非常地特别，它引起过许多
争议，但是这条语句仍然一直被保留了下来，即便是今天的C++语言中，也有对它的支持(虽然不建议使用它)。</p>

<!-- more -->
<p>goto语句有非常多的用途或优点，例如，它特别适合于在编写系统程序中被使用，它能使编写出来的代码非常简练。另外，goto语句
另外一个最重要的作用就是，它实际上是一种对异常处理编程，最初也最原始的支持手段或方法。它能把错误处理模块的代码有效与其
它代码分离开来。例程如下</p>
{% codeblock %}
void main(int argc, char* argv[])  
{  
　　if (Call_Func1(in, param out) {  
　　　　// 函数调用成功，我们正常的处理  
　　　　if (Call_Func2(in, param out) {  
　　　　// 函数调用成功，我们正常的处理  
　　　　　　while(condition) {  
　　　　　　　　//do other job  
　　　　　　　　// 如果错误直接跳转  
　　　　　　　　if (has error) goto Error;  
　　　　　　//do other job  
　　　　　　}  
　　　　}  
　　　　// 如果错误直接跳转  
　　　　else goto Error;  
　　}  
　　// 如果错误直接跳转  
　　else goto Error;  
　　// 错误处理模块  
Error:  
　　process_error();  
　　exit();  
}
{% endcodeblock %}
<p>虽然goto 语句能有效地支持异常处理编程的实现。但是没有人却建议使用它，即便是在C语言中。因为：</br>
(1) goto语句能破坏程序的结构化设计，使代码难于测试，且包含大量goto的代码模块不易理解和阅读。它一直遭结构化程序设计思想所抛弃，强烈建议程序员不易使用它;</br>
(2) 与C++语言中提供的异常处理编程模型相比，它的确是太弱了一些。例如，它一般只能是在某个函数的局部作用域内跳转，也即它不能有效和方便地实现程序控制流的跨函数远程的跳转。</br>
(3) 如果在C++语言中，用goto语句来实现异常处理，那么它将给面向对象构成极大破坏，并影响到效率。这一点，以后会继续深入阐述。</p>

<p>虽然goto语句缺点多多，但不管如何，goto语句的确为程序员朋友们，在C语言中，有效运用异常处理思想来进行编程处理，提供了一种途径或简易的手段。
当然，运用goto语句来进行异常处理编程已经成为历史。因为，在C语言中，早就已经提供了一种更加优雅的异常处理机制。</p>

<h2>3.更优雅的异常处理机制：setjmp()函数与longjmp()函数</h2>
<p>C标准库提供两个特殊的函数：setjmp() 及 longjmp()，这两个函数是结构化异常的基础，正是利用这两个函数的特性来实现异常。</p>
<p>所以，异常的处理过程可以描述为这样：</br>
·首先设置一个跳转点（setjmp() 函数可以实现这一功能），然后在其后的代码中任意地方调用 longjmp() 跳转回这个跳转点上，
以此来实现当发生异常时，转到处理异常的程序上，在其后的介绍中将介绍如何实现。</br>
·setjmp() 为跳转返回保存现场并为异常提供处理程序，longjmp() 则进行跳转（抛出异常），setjmp() 与 longjmp() 可以在函数
间进行跳转，这就像一个全局的 goto 语句，可以跨函数跳转。</p>

<p>举个例子，程序在 main() 函数内使用 setjmp() 设置跳转，并调用另一函数A，函数A内调用B，B抛出异常（调用longjmp() 函数），
则程序直接跳回到 main() 函数内使用 setjmp() 的地方返回，并且返回一个值。</p>

<h4>jmp_buf 异常结构</h4>
<p>使用 setjmp() 及 longjmp() 函数前，需要先认识一下 jmp_buf 异常结构。jmp_buf 将使用在 setjmp() 函数中，用于保存当前程序现场（保存
当前需要用到的寄存器的值），jmp_buf 结构在 setjmp.h 文件内声明：</p>
{% codeblock %}
typedef struct
{
	unsigned j_sp;  // 堆栈指针寄存器
	unsigned j_ss;  // 堆栈段
	unsigned j_flag;  // 标志寄存器
	unsigned j_cs;  // 代码段
	unsigned j_ip;  // 指令指针寄存器
	unsigned j_bp; // 基址指针
	unsigned j_di;  // 目的指针
	unsigned j_es; // 附加段
	unsigned j_si;  // 源变址
	unsigned j_ds; // 数据段
} jmp_buf;
{% endcodeblock %}
<p>jmp_buf 结构存放了程序当前寄存器的值，以确保使用 longjmp() 后可以跳回到该执行点上继续执行。</p>

<h4>setjmp() 与 longjmp() 函数详细说明</h4>
<p>setjmp() 与 longjmp() 函数原型如下：</p>
{% codeblock %}
void _Cdecl longjmp(jmp_buf jmpb, int retval);
int _Cdecl setjmp(jmp_buf jmpb);
{% endcodeblock %}

<p>_Cdecl 声明函数的参数使用标准C的进栈方式（由右向左）压栈，_Cdecl 是C语言的一种调用约定，除此以外，PASCAL 也是
调用约定之一。C标准调用约定（_Cdecl）所声明的函数不自动清除堆栈，这一事务由调用者自行负责——这也是C可以支持不固定
个数的参数的原因。此外，这一调用约定将在函数名前添加一个下划线字符，如某一函数声明为：</p>
{% codeblock %}
int cdecl DoSomething(void);
{% endcodeblock %}
<p>编译时将自动为 DoSomething 加上下划线前缀，即函数名变为：_DoSomething。</p>

<p>setjmp() 与 longjmp() 函数都使用了 jmp_buf 结构作为形参，它们的调用关系是这样的：</br>
首先调用 setjmp() 函数来初始化 jmp_buf 结构变量 jmpb，将当前CPU中的大部分影响到程序执行的寄存器的值存入 jmpb，
为 longjmp() 函数提供跳转，setjmp() 函数是一个有趣的函数，它能返回两次，它应该是所有库函数中唯一一个能返回两次
的函数，第一次是初始化时，返回零，第二次遇到 longjmp() 函数调用后，longjmp() 函数使 setjmp() 函数发生第二次返回，
返回值由 longjmp() 的第二个参数给出（整型，这时不应该再返回零）。</p>

<p>在使用 setjmp() 初始化 jmpb 后，可以其后的程序中任意地方使用 longjmp() 函数跳转会 setjmp() 函数的位置，longjmp() 
的第一个参数便是 setjmp() 初始化的 jmpb，若想跳转回刚才设置的 setjmp() 处，则 longjmp() 函数的第一个参数是 setjmp() 
所初始化的 jmpb 这个异常，这也说明一件事，即 jmpb 这个异常，一般需要定义为全局变量，否则，若是局部变量，当跨函数调用
时就几乎无法使用（除非每次遇到函数调用都将 jmpb 以参数传递，然而明显地，是不值得这样做的）；longjmp() 函数的第二个参数
是传给 setjmp() 的第二次返回值，这在介绍 setjmp() 函数时已经介绍过。</p>

<h4>异常处理过程</h4>
<p>先来对比（参考）一下 C++ 的异常处理，C++ 在语言层上便添加了异常处理机制，使用 try 块来包含那些可能出现错误的代码，
你可以在 try 块代码中抛出异常，C++ 使用 throw 来抛出异常。抛出异常后，将转到异常处理程序中执行，C++ 使用 catch 块来
包含那些处理异常的代码，catch 块可以接收不同类型的异常。需要说明的是，throw 一般不在 try 块内的代码中抛出异常，try 
块内的代码调用了别的函数，如函数A，函数A 又调用了函数 B，throw 可以在函数B中抛出异常，或者更深的函数调用层，无论如何，
只要有异常抛出，程序将转到 catch 处执行。</p>

<p>C中如何实现，或者明确地说是模拟这一功能？下面介绍的是一些简单的方法。现在假设 longjmp() 第二个值为1，即 setjmp() 
第二次将返回1。我们使用一组简单的宏来替代 setjmp() 和 longjmp() 以便使用：</br>
首先定义一个全局的异常：</p>
{% codeblock %}
jmp_buf Jump_Buffer;
{% endcodeblock %}

<p>因为 setjmp() 第一次调用初始化后返回0，第二次返回非0，可以这样定义一个宏使得它功能接近于 C++ 的 try。</p>
{% codeblock %}
#define try if(!setjmp(Jump_Buffer))
{% endcodeblock %}

<p> 当 setjmp() 函数第一次0 时，取非为真，则执行 try 块内的代码，如：</p>
{% codeblock %}
try {
	Test();
}
{% endcodeblock %}

<p>当因为调用 longjmp() 抛出异常而导致 setjmp() 第二次返回时（程序将会转到 setjmp() 函数处返回，这时，这时应该执行
的是异常处理代码。longjmp() 使 setjmp() 函数返回非0，if(!setjmp(JumpBuffer)) 中将值取非则为假，是以，异常处理放在
其后应该使用一个 else：</p>
{% codeblock %}
#define catch else
{% endcodeblock %}

<p>如此看起来便跟 C++ 相似了，setjmp() 函数的第二次返回导致 if() 中表达式值为假，刚好使 catch 块得以执行，如：</p>
{% codeblock %}
try  {
	Test();
} catch {
	puts("Error");
}
{% endcodeblock %}

<p>实现如 C++ 的 throw 语句，事实上以宏替换 longjmp(jmp_buf, int) 的调用：</p>
{% codeblock %}
#define throw longjmp(Jump_Buffer, 1)
{% endcodeblock %}

<p>下面的例程解释如何使用这些宏：</p>
{% codeblock %}
#include"stdio.h"  
#include"conio.h"  
#include"setjmp.h"  
jmp_buf Jump_Buffer;  
#define try if(!setjmp(Jump_Buffer))  
#define catch else  
#define throw longjmp(Jump_Buffer,1)  
int Test(int T)  
{  
    if(T>100)  
        throw;  
    else  
          puts("OK.");  
    return 0;  
}  
int Test_T(int T)  
{  
    Test(T);  
    return 0;  
}  
int main()  
{  
    int T;  
    try{  
          puts("Input a value:");  
          scanf("%d",&T);  
          T++;  
          Test_T(T);  
      } catch{  
          puts("Input Error!");  
      }  
    getch();  
    return 0;  
}
{% endcodeblock %}
