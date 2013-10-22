---
layout: post
title: "C语言断言简介"
date: 2011-05-03 10:31
comments: true
categories: Program
tags: C assert debug
---
<h2>1.概述</h2>
<p> 断言是对某种假设条件进行检查（可理解为若条件成立则无动作，否则应报告），它可以快速发现并定位软件问题，
同时对系统错误进行自动报警。断言可以对在系统中隐藏很深，用其它手段极难发现的问题进行定位，从而缩短软件问题定位时间，
提高系统的可测性。实际应用时，可根据具体情况灵活地设计断言。</p>

<h2>2.标准断言机制</h2>
<p>原型定义：</p>
{% codeblock %}
#include <assert.h>
void assert( int expression_r_r_r );
{% endcodeblock %}
<p>assert的作用是现计算表达式 expression_r_r_r ，如果其值为假（即为0），
那么它先向stderr打印一条出错信息，然后通过调用 abort来终止程序运行。</p>

<!-- more -->
<h2>3.简单实例</h2>
<p>下面给一个断言的简单实例：</p>
{% codeblock %}
#include <stdio.h>  
#include <assert.h>  
#include <stdlib.h>  
int main( void )  
{  
   FILE *fp;  
 
   fp = fopen( "test.txt", "w" );//以可写的方式打开一个文件，如果不存在就创建一个同名文件  
   assert( fp );         //所以这里不会出错  
   fclose( fp );  
 
   fp = fopen( "noexitfile.txt", "r" );//以只读的方式打开一个文件，如果不存在就打开失败  
   assert( fp );         //所以这里出错  
   fclose( fp );         //程序永远都执行不到这里来  
   return 0;  
}
{% endcodeblock %}

<h2>4.断言用法详解</h2>
<p>1)在函数开始处检验传入参数的合法性，如:</p>
{% codeblock %}
int resetBufferSize(int nNewSize)
{
  //功能:改变缓冲区大小,
  //参数:nNewSize 缓冲区新长度
  //返回值:缓冲区当前长度
  //说明:保持原信息内容不变，nNewSize<=0表示清除缓冲区
  assert(nNewSize >= 0);
  assert(nNewSize <= MAX_BUFFER_SIZE);
  //...
}
{% endcodeblock %}

<p>2)每个assert只检验一个条件,因为同时检验多个条件时,如果断言失败,无法直观的判断是哪个条件失败</p>
{% codeblock %}
assert(nOffset>=0 && nOffset+nSize<=m_nInfomationSize);  //不好
assert(nOffset >= 0);   //好
assert(nOffset+nSize <= m_nInfomationSize);
{% endcodeblock %}

<p>3)不能使用改变环境的语句,因为assert只在DEBUG个生效,如果这么做,会使用程序在真正运行时遇到问题</p>
{% codeblock %}
assert(i++ < 100);  //错误
{% endcodeblock %}
<p>这是因为如果出错，比如在执行之前i=100,那么这条语句就不会执行，那么i++这条命令就没有执行。</p>
{% codeblock %}
assert(i < 100);    //正确
i++;
{% endcodeblock %}

<p>4)assert和后面的语句应空一行,以形成逻辑和视觉上的一致感</p>

<p>5)有的地方,assert不能代替条件过滤</p>

<h2>5注意事项：</h2>
<p>1).使用assert的缺点是，频繁的调用会极大的影响程序的性能，增加额外的开销。
在调试结束后，可以通过在包含#include <assert.h>的语句之前插入 #define NDEBUG 来禁用assert调用，
示例代码如下：</p>
{% codeblock %}
#include <stdio.h>
#define NDEBUG
#include <assert.h>
{% endcodeblock %}

<p>2).ASSERT只有在Debug版本中才有效，如果编译为Release版本则被忽略掉。（在C中，ASSERT是宏而不是函数），
使用ASSERT“断言”容易在debug时输出程序错误所在。而assert()的功能类似，它是ANSI C标准中规定的函数，
它与ASSERT的一个重要区别是可以用在Release版本中。</p>

<h3>推荐阅读</h3>
<a href="http://www.cppblog.com/oosky/archive/2006/03/26/4625.html#_Toc131314725">华为软件编程规范</a>
