---
layout: post
title: "《Neural Networks: A Comprehensive Foundation》读书笔记"
date: 2018-07-07 23:38
comments: true
categories: Reading
tags: 机器学习 神经网络
---

<center>{% img /images/2018/IMAG2018070701.png %}</center>

近几年AI大火，深度学习作为AI领域最火的研究子方向，从最早的RBM、Auto-encoder、最原始的CNN、RNN到LeNet、AlexNet、VGG、GoogLeNet、ResNet等多样化的深度网络，深度学习的算法和模型层出不穷，发展迅猛，但所有这些模型的低层原理和子单元却是大同小异殊途同归的。Simon Haykins 这本书详细解读了神经网模型的底层原理、中层的方法论和思想总结、上层复杂模型的构建和应用，虽然这本书出版比较早，但其中的基础原理和方法论一点也不过时，对于理解神经网络和深度学习模型很有帮助，非常值得仔细研读。

以下是精读过程中，做的一些简要的记录，对该书感兴趣而又没有时间细读全书的同学，可以根据以下内容，选择性的挑选相关章节阅读 :) （个人认为前三部分内容是比较普适性的方法论，讲得比较精彩，推荐精读）

<!-- more -->

### 一、关于Knowledge Representation
第一章主要介绍性的内容，值得一提的是1.7节中关于Knowledge Representation的内容讲得比较好！（在我的blog中也有具体记述：[神经网络的学习方法概述](http://ibillxia.github.io/blog/2013/03/27/learning-process-of-neural-networks/)）

首先是知识的定义，然后是知识的表示，再然后该书将现实世界的知识分为先验知识和观察数据两种，其中后者包含有label的和无label的。

后面还详细讲述了在Neural Networks模型中知识的表示应该满足的4个规则、2种将先验知识融入NN中的方法、3种将Invariances(不变性，恒定性)融入到NN的方法等。具体可以看blog。

### 二、关于Learning Process
该书的第二章主要讲的是NN的学习方法。

主要从基本学习方法（5种）、学习策略（Credit-Assignment问题、监督/非监督学习）、学习任务（6种）、自适应（Adaptation）、学习过程的统计学理论等方面来讲述。

其中前面几部分在上述blog中有所简略记述，关于学习过程的统计学理论方面，该书首先提到了其中的期望、方差估计等，然后提出了一个很重要的问题，即关于Variance/Bias Dilemma的问题。再然后将实际问题用严谨的统计学理论来表述和建模，并提出了结构风险最小化原理、VC维的概念实例及其估算、学习机器泛化能力的边界约束等。最后讲述了学习机器的PAC（Probably Approximate Correct，概率近似正确）理论。

### 三、关于感知机（Perceptron）
第3章讲单层感知机，第4章讲多层感知机。

第3章中值得一提的是，在3.3节中在提出了梯度下降的学习方法后，指出该方法学习速率难定等缺陷，然后提出了Newton方法、Gauss-Newton方法等。

第4章中值得一提的是，在4.6节的第一段中就指出了多层感知机（MLP）的BP算法的由于其可设置的参数太多而被称为more of an art than a science，其好坏在很大程度上是与设计者的经验有关的，并指出八个有利于提升算法效率的方面：

- （1）sequencial mode is computationally faster than batch mode；
- （2）maximizing information content；实现方法是：选择那些是训练误差更大的样本、与之前出现的样本差异更大的样本；
- （3）激活函数：一般而言反对称的激活函数（如tanh函数）比非对称的激活函数（如logistic函数）学习得更快；
- （4）Target values：目标输出应该落在激活函数的值域范围内；
- （5）输入数据规整：训练集输入数据的均值应该接近0，数据点之间不相关，每个维度上的方差相近；
- （6）初始化：初始化的权重的均值为0，方差为神经元链接到的突触的个数的-1/2次方；
- （7）Learning from hints：将关于训练数据的一些先验知识引入进来，比如方差信息、对称性等，以加快训练速度，同时提升系统性能；
- （8）学习速率：每个神经元的学习速率最好是相同的，一般上层的比下层的具有更大的局部梯度，这样上层的学习速率应该设置得更小；另外，包含更多输入的神经元的学习速率应该更小。

这几个经验非常重要。

还有，在4.15节中讲到了NN的裁剪技术，主要有两种思路，一种是Regularization（正则化），另一种是Deletion（删除）。

### 四、径向基（RBF）神经网络
第5章主要讲RBF（Radial Basis Function）神经网络。

RBF神经网络是一个三层网络，除了输入、输出外仅有一个隐层，隐层的激活函数是高斯函数等钟形函数，输入节点与权重的距离作为高斯函数的指数，由于距离是径向同性的，因而称为径向基函数。

在5.11节，将RBF与MLP进行了详细比较。

在5.13节中介绍了几种RBF的学习策略，主要是中心点的选取，而关于网络的训练、优化、正则化、泛化等则再前几节中讲解了。

### 五、SVM、Boosting、PCA等
为什么在神经网络的书中单独开一章来讲SVM呢？因为最基本的SVM是线性模型，可以看做是单层感知机或多层感知机的顶层。而引入核函数后，就变成非线性分类器，但仍然可以看作为NN中的某一层。

关于SVM的具体原理和方法这本书就讲得不是很详细了，可以参看John Shawe-Taylor & Nello Cristianini编写的两本书：《Support Vector Machines》和《Kernel Methods for Pattern Analysis》。

第7章讲的Committee Machine（委员会机）的基本思想是分而治之，即将输入样本分为几分，每一份分别用各自的模型或方法来学习，然后综合这多个系统的结果来进行决策。最典型的例子就是Boosting。

第8章将主成分分析（Principal Component Analysis，PCA），对特征进行线性变换，用于降维等。最后还提到了Kernel-PCA，这就是对特征的非线性变换了。

### 六、自组织特征映射（SOM）神经网络
第9章讲自组织特征映射（Self-Organise Map，SOM）神经网络。

SOM的基本思想是网络在接受外界输入模式时，将会分为不同的对应区域，各区域对输入模式具有不同的相应特征，并且这个过程是自动完成的。SOM与人脑的自组织特征类似。

9.4节将SOM算法的步骤进行了总结，将其分为5大步：初始化、采样、相似性匹配、更新、Continuation(附加)。

9.5节对SOM的一些重要特性进行了梳理，主要是4个方面：输入空间的逼近、拓扑顺序、疏密匹配、特征选择。

### 七、信息论与统计机器学习
第10章讲信息论，第11章将统计机器学习。

信息论里面主要讲到了熵（Entropy）、最大熵原则、互信息、K-L距离、互信息最大化原则等基本概念和原理，还有就是信息熵的应用，比如用来做冗余消除（Redundancy Reduction），独立成分分析（independent component analysis，ICA）等等。

统计机器学习里面主要内容有统计原理、Markov链、Metropolis算法、模拟退火算法、吉布斯采样、玻尔兹曼机、置信网络、Holmholtz机等。Markov链在语音识别中用得比较多，而Metropolis算法是用来生成可逆Markov链的，进而可以构造MCMC算法。而模拟退火算法是基于Monte-Carlo迭代求解策略的一种随机寻优算法，理论上具有概率的全局优化性。吉布斯采样与Metropolis算法类似，只是它是用来生成基于Gibbs分布Markov链。Holmholtz机类似与Sigmoid置信网络，只是他的网络连接分为前向连接（用于识别）和反向连接（类似生成模型），而其学习过程分为清醒和睡眠两个过程，分别对这两部分连接的权重进行学习。

### 八、增强学习
第12章讲神经元动态规划。

神经元动态规划中主要讲了Markovian决策过程、Bellman优化准则、策略迭代、值迭代、Q-学习等。其中最基础的是马尔科夫决策过程，而后面的一些理论和方法都是MDP的学习策略和算法。

### 九、其他话题
第13章讲在时间序列中使用网络模型。第14章和第15章主要是反馈（Recurrent）神经网络。

神经网络用于时间序列识别的模型有NETtalk、TDNN、TLFN等。

反馈神经网络主要包含Hopfield模型、Cohen-Grossberg理论、Attractor（吸引子）、Chaotic（混沌）、状态-空间模型、Kalman滤波等。
