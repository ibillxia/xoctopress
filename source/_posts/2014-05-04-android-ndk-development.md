---
layout: post
title: "Ubuntu 下 Android NDK 开发入门"
date: 2014-05-04 23:53
comments: true
categories: Program
tags: Android NDK JNI
---

本文首先介绍一下在 Ubuntu 下如何配置 Android NDK 开发环境，然后用一个简单的 hello-jni 项目来介绍 NDK 开发流程，本文的全部代码下载链接：[HelloJni.tar.gz](http://ibillxia.github.io/upload/code/20140504-HelloJni.tar.gz)，也可以在我的 [GitHub](https://github.com/ibillxia/Demo/tree/master/HelloJni) 上下载。

## 1. 简介
什么是 Android NDK 呢？ NDK(Native Development Kit) 是一个允许开发者用一些本地语言(C/C++)编写 Android App 的部分功能的工具集。对于一些特定的 App，NDK 非常有利于我们直接使用现成的用 C/C++ 编写的代码库（但对于大多数 App 来说，NDK 是没有必要的）。使用 NDK 进行 C/C++ Android 开发的基本结构和流程如下图（来自[shihongzhi博客](http://shihongzhi.com/ndk/) ）：
<center> {% img /images/2014/IMAG2014050401.jpg %} </center>

在开始之前，这里要提醒大家：NDK 对大多数 App 而言是不会有太多的好处的，在 Android 上使用原生 C/C++ 代码并不会很明显的提升应用的性能，但却增加了你开发应用的复杂度。所以，仅仅在需要使用 NDK 时才使用它 —— 不要因为你更喜欢用 C/C++。典型的 NDK 应用场景是一些 CPU 操作密集而不需要太多内存的场合，如信号处理、物理模拟等等，很多这些处理过程都已经封装到了 Android 系统内部，所以当你不确定是否要使用本地 C/C++ 代码时，先看看你的需求，以及 Android 框架中的 API 是否已经提供你需要的功能。

<!-- more -->

## 2.开发环境配置
由于 NDK 开发过程中涉及到将 C/C++ 程序编译为动态库(.so文件)，所以首先系统中需要安装 C/C++ 的编译工具 gcc/g++，还要有 make 工具，一般情况下 Linux 系统会默认安装，如果没有安装请先安装这几个工具。然后是 Java 和 Android 开发相关环境的配置。首先需要安装 JDK，并配置 Java 的环境变量，然后是集成开发环境如 Eclipse 的安装和配置，这些也不是本文的重点，如果你没有安装，请自行 google 并安装配置好。 

下面重点讲讲 Android 相关 SDK 的安装和配置，主要涉及到 Android SDK，ADT，NDK等。要进行 Android 开发，首先需要安装 Android SDK，要在 Eclipse 中进行开发的话，还需在 Eclipse 中安装 ADT(Android Develop Tools)，在 Android 官网上提供了 SDK 和 包含 ADT 的 Eclipse 的集成开发包，可以一起下载：[adt-bundle-linux-x86-20140321.zip](http://dl.google.com/android/adt/22.6.2/adt-bundle-linux-x86-20140321.zip)。另外，还需要安装 NDK，下载地址：[android-ndk-r9d-linux-x86.tar.bz2](http://dl.google.com/android/ndk/android-ndk-r9d-linux-x86.tar.bz2)。下载完这两个压缩包后解压并移动到 /usr/local 目录下：

``` 
sudo mv Downloads/adt-bundle-x86-20140321/ /usr/local/adt-x86-20140321 
mv Downloads/android-ndk-r9d/ /usr/local/adt-x86-20140321/ndk-r9d 
``` 

然后配置环境变量： 

``` 
sudo vim /etc/profile 
``` 

在 /etc/profile 最后添加如下两行： 

``` 
export PATH=/usr/local/adt-x86-20140321/sdk/tools:/usr/local/adt-x86-20140321/sdk/platform-tools:$PATH 
export PATH=/usr/local/adt-x86-20140321/ndk-r9d:$PATH 
``` 

保存并退出，并用如下命令使设置生效： 

``` 
source /etc/profile 
``` 

完了可以执行如下命令看看设置是否生效： 

``` 
echo $PATH 
adb --version 
emulator -version 
ndk-build --version 
``` 

至此，开发环境已经配置完成了，接下来我们看一个 hello-jni 的例子。 

## 3.NDK 开发实例 hello-jni 
#### 3.1 JNI 简介 
首先我们了解一下什么是JNI。JNI(Java Native Interface)是一种在Java虚拟机控制下执行代码的标准机制。 代码被编写成汇编程序或者C/C++程序，并组装为动态库，从而提供了一个在Java平台上调用C/C++的一种途径。 JNI主要的竞争优势在于：它在设计之初就确保了二进制的兼容性，JNI编写的应用程序兼容性以及在某些具体平台上的Java虚拟机兼容性（当谈及JNI，这里并不特别针对Dalvik；JNI由Oracle开发，适用于所有Java虚拟机）。 关于JNI的更多内容可以参见该文：[Android NDK介绍](http://www.importnew.com/8038.html)。 

#### 3.2 Eclipse 配置
下面以参考 Android NDK 自带的 hello-jni 示例程序改写的我自己的 hello-jni 来介绍开发流程。首先打开 Eclipse 并配置 Android SDK 和 NDK 的路径。 选择 Eclipse 的如下菜单：Window =&gt; Preferences =&gt; Android，点击浏览按钮设置 SDK 路径；Window =&gt; Preferences =&gt; Android =&gt; NDK，点击浏览按钮设置 NDK 路径。接下来按照简介中的开发流程图来一步一步介绍 NDK 开发步骤。 

#### 3.3 创建 Android App 并添加 Native Support 
首先用Eclipse 创建一个空的 Android App，命名为 HelloJni。在项目上点击右键，选择 Android Tools =&gt; Add Native Support... ，在弹出的对话框中填入 HelloJni 并确定，会发现项目中多了一个 jni 目录，并自动生成了 HelloJni.cpp 和 Android.mk 文件，分别是我们需要封装的native C++ 代码和编译它的 Makefile 文件。 

#### 3.4 编写 java API 
原本按照图一中的流程我们需要先编写一些 C/C++ 原生的代码，但实际中，为了简便起见，我们可以使用 jdk 的 javah 工具（如果没有， `sudo apt-get update` 一下）来根据 java 调用 C/C++ API 的接口类来自动生成 jni 的头文件。因此，我们需要先做第3步的内容，这里编写的 Java API 接口 HelloCal 类（在 `src/io.ibillxia.hellojni` 路径下）如下： 

```
//HelloCal.java
package io.ibillxia.hellojni; 

public class HelloCal { 
	static { 
		System.loadLibrary("HelloJni"); // 加载 jni 动态库 
	} 
	
	public native String helloSay(); // 返回字符串 
	public native int helloAdd(int a,int b); // 两个整数相加 
	public native int helloSub(int a,int b); // 两个整数相减 
	public native int helloMul(int a,int b); // 两个整数相乘 
	public native int helloDiv(int a,int b); // 两个整数相除 
} 
``` 

#### 3.5 使用 javah 生成 jni 格式的 C/C++ API 
编写完 java API 后在 Eclipse 中 build 一下生成对应 .class 文件，然后使用 javah 工具根据该 class 文件自动生成 jni API 的头文件。在 HelloJni App 根目录下执行如下命令： 

``` 
javah -classpath ./bin/classes -d jni io.ibillxia.hellojni.HelloCal 
``` 

其中 `-classpath ./bin/classes` 表示类的路径，`-d jni` 表示生成的头文件存放的目录， `io.ibillxia.hellojni.HelloCal` 则是完整类名，如果不出意外，在 `~/workspace/HelloJni/jni` 目录下生成了 `io_ibillxia_hellojni_HelloCal.h` 。然后根据这个头文件的内容，编写 `HelloCal.cpp` 文件实现头文件中声明的接口，具体的头文件和 cpp 源文件内容见源码压缩包。值得一提的是，在 cpp 源文件中，对数据运算后可能产生溢出进行了判断，对于溢出异常这里处理的办法是，如果上溢则返回最大值，下溢则返回最小值。实际中，这样做可能还不是很合理，比较好的做法是，在 cpp 中处理并返回异常值，并在相应的 Java API 中针对返回的异常值进行不同的处理，即在 cpp 中只检查异常，而真正处理异常则由 Java API 来处理。 

注意，这里需要添加一下 C/C++ 的包含目录，否则会报错。选中 jni文件夹，右键选择 Properties =&gt; C/C++ General =&gt; Paths and Symbols =&gt; Includes，点击 Add 一个一个添加如下依赖库： 


> /usr/include  
> /usr/include/c++/4.8  
> /usr/include/c++/4.8/backward  
> /usr/include/i386-linux-gnu  
> /usr/include/i386-linux-gnu/c++/4.8  
> /usr/lib/gcc/i686-linux-gnu/4.8/include  
> /usr/lib/gcc/i686-linux-gnu/4.8/include-fixed  
> /usr/local/include  
> /usr/local/adt-x86-20140321/ndk-r9d/platforms/android-19/arch-arm/usr/include  


添加完后 build 一下，看看是否有错误，如果不出意外，应该在 `HelloJni/libs/armeabi/` 目录下生成了 `libHelloJni.so` 文件。 

#### 3.6 编写 Android App 
最后是编写 Android App，并在 App 中调用 Jni 接口函数。在 `io.ibillxia.hellojni` 包中新建一个 Java 类 HelloJni ，编写如下代码（import 内容省略，具体见源码压缩包）： 

```
//HelloJni.java
public class HelloJni extends Activity {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.hello_jni);
        
        Button btn = (Button)findViewById(R.id.btn_cal);
        btn.setOnClickListener(new Button.OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				TextView tv1 = (TextView) findViewById(R.id.textView1);
				TextView tv2 = (TextView) findViewById(R.id.textView2);
				TextView tv3 = (TextView) findViewById(R.id.textView3);

				int a = Integer.parseInt(tv1.getText().toString());
				int b = Integer.parseInt(tv2.getText().toString());
				HelloCal cal = new HelloCal();
				int c = cal.helloAdd(a,b);
				String str = cal.helloSay();  
				tv3.setText(str + Integer.toString(c));
			}
        });
    }
}
``` 

另外，还需要设计对应的 layout xml 文件，具体见源码压缩包。 最后上一张运行效果截图：
{% img /images/2014/IMAG2014050402.png %}
图中输入的两个数的和超过了 int 能表示的最大值，出现上溢，但返回的是最大值。如果输入的两个数本身就超出范围将出现 
`Unfortunately, HelloJni has stopped.` 的异常的对话框。实际过程中，究竟在哪一步检测并处理异常，还是一个值得商讨的问题。如果是引用第三方的库，可能需要对相应的接口提供充分的测试，对于可以并且方便在 native code 层面解决的异常就在 native code 层面上处理掉，实在不行也要在 Java API 层面上解决掉，比如这里需要在 Java 中判断输入参数本身的合法性。

