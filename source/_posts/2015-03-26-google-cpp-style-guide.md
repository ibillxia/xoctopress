---   
layout: post   
title: "Google C++ 编程规范要点总结"   
date: 2015-03-26 18:45   
comments: true   
categories: Program   
tags: C++ Google 编码规范 代码质量   
---   

<center>{% img /images/2015/IMAG2015032601.png %}</center>

Google C++ Style Guide是业界最为著名的C++编程规范之一。本文对其核心要点进行梳理总结，涵盖头文件管理、命名规范、类设计、内存管理等方面。   
   
# 1. 头文件（Header Files）   
通常每个 `.cc` 文件应该有一个配套的 `.h` 文件. 常见的例外情况包括单元测试和仅有 `main()` 函数的 `.cc` 文件.     
正确使用头文件会大大改善代码的可读性和执行文件的大小、性能.    

- 每个.cc文件都应有一个对应的.h文件     
- 使用#define保护头文件防止多重包含，格式：`PROJECT_PATH_FILE_H_`    
- 尽量使用前置声明（Forward Declarations）减少 `#include` 的数量   
- 内联函数不超过10行    
   
<!--more-->   
   
# 2. 命名规范（Naming）   
最重要的一致性规则是命名管理. 命名的风格能让我们在不需要去查找类型声明的条件下快速地了解某个名字代表的含义: 类型, 变量, 函数, 常量, 宏, 等等, 甚至. 我们大脑中的模式匹配引擎非常依赖这些命名规则.

命名规则具有一定随意性, 但相比按个人喜好命名, 一致性更重要, 所以无论你认为它们是否重要, 规则总归是规则.

- <b>文件名</b>：全部小写，用下划线连接，如 `my_useful_class.cc`     
- <b>类型名</b>：大驼峰，如 `MyExcitingClass`    
- <b>变量名</b>：全部小写加下划线，如 `table_name`；类成员变量加尾部下划线 `table_name_`    
- <b>常量名</b>：以k开头后跟大驼峰，如 `kDaysInAWeek`    
- <b>函数名</b>：大驼峰，如 `AddTableEntry()`     
- <b>命名空间</b>：全部小写加下划线   
   
# 3. 类（Classes）   
类 (class) 是 C++ 中最基本的代码单元. 因此，类在 C++ 中被广泛使用.   

- 构造函数中不要做过于复杂的初始化，考虑使用 `Init()` 方法     
- 必须定义拷贝构造函数和赋值操作符，或使用 `DISALLOW_COPY_AND_ASSIGN` 宏禁用     
- 优先使用组合（Composition）而非继承（Inheritance）     
- 接口类只有纯虚函数和静态成员     
- 声明顺序：`public` → `protected` → `private`     
   
# 4. 格式（Formatting）   
每个人都可能有自己的代码风格和格式, 但如果一个项目中的所有人都遵循同一风格的话, 这个项目就能更顺利地进行.   
每个人未必能同意下述的每一处格式规则, 而且其中的不少规则需要一定时间的适应, 但整个项目服从统一的编程风格是很重要的, 只有这样才能让所有人轻松地阅读和理解代码.  

- 每行最多80个字符     
- 使用2个空格缩进，不使用Tab     
- 函数声明和定义的返回类型与函数名在同一行     
  
# 5. 其他C++特性   
- 优先使用const引用传递参数     
- 避免使用异常（Exceptions）     
- 使用C++风格的类型转换（static_cast等），禁止C风格强转     
- 使用前置递增（++i）而非后置递增（i++）     
- 使用nullptr替代NULL和0     
 
# 参考资料     
[1][Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)     
[2][C++ 风格指南](https://zh-google-styleguide.readthedocs.io/en/latest/google-cpp-styleguide/contents.html)   
