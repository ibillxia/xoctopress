---   
layout: post   
title: "PyTorch+CUDA+显卡算力对应关系"   
date: 2024-07-04 17:06   
comments: true   
categories: DataScience   
tags: PyTorch CUDA GPU 深度学习   
---   

# Pytorch 各个GPU版本CUDA和cuDNN对应版本

[https://blog.csdn.net/weixin_45508265/article/details/122006134](https://blog.csdn.net/weixin_45508265/article/details/122006134)

[https://pytorch.org/get-started/previous-versions/](https://pytorch.org/get-started/previous-versions/)

<center>{% img /images/2024/IMAG2024070401.png %}</center>

<!--more-->

# pytorch 中注意cuda版本和gpu算力匹配

[https://blog.csdn.net/m0_46483236/article/details/124112298](https://blog.csdn.net/m0_46483236/article/details/124112298)

[https://zhuanlan.zhihu.com/p/427395039](https://zhuanlan.zhihu.com/p/427395039)

[https://docs.nvidia.com/cuda/ampere-compatibility-guide/index.html#verifying-ampere-compatibility-using-cuda-11-0](https://docs.nvidia.com/cuda/ampere-compatibility-guide/index.html#verifying-ampere-compatibility-using-cuda-11-0)

查看GPU算力：[https://developer.nvidia.com/cuda-gpus](https://developer.nvidia.com/cuda-gpus)

**只有cuda 11版本支持当前GPU 8.6算力**

安装cuda 11.1覆盖cuda 10.2。

pip3 install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio==0.9.0 -f [https://download.pytorch.org/whl/torch_stable.html](https://download.pytorch.org/whl/torch_stable.html)

查看cuda+torch版本及算力（[https://developer.aliyun.com/article/1374303](https://developer.aliyun.com/article/1374303)）

<center>{% img /images/2024/IMAG2024070402.png %}</center>

# nvcc和nvidia-smi显示的版本不一致？

[https://www.jianshu.com/p/eb5335708f2a](https://www.jianshu.com/p/eb5335708f2a)

**nvcc 属于CUDA的编译器，将程序编译成可执行的二进制文件。**

**nvidia-smi 全称是 NVIDIA System Management Interface ，是一种命令行实用工具，旨在帮助管理和监控NVIDIA GPU设备。 **

CUDA有 runtime api 和 driver api，两者都有对应的CUDA版本， nvcc --version 显示的就是前者对应的CUDA版本，而 nvidia-smi显示的是后者对应的CUDA版本。 

用于支持driver api的必要文件由 GPU driver installer 安装，nvidia-smi就属于这一类API；而用于支持runtime api的必要文件是由 CUDA Toolkit installer 安装的。nvcc是与CUDA Toolkit一起安装的CUDA compiler-driver tool，它只知道它自身构建时的CUDA runtime版本，并不知道安装了什么版本的GPU driver，甚至不知道是否安装了GPU driver。 CUDA Toolkit Installer通常会集成了GPU driver Installer，如果你的CUDA均通过CUDA Tooklkit Installer来安装，那么runtime api 和 driver api的版本应该是一致的，也就是说， nvcc --version 和 nvidia-smi 显示的版本应该一样。否则，你可能使用了单独的GPU driver installer来安装GPU dirver，这样就会导致 nvidia-smi 和 nvcc --version 显示的版本不一致了。 

**通常，driver api的版本能向下兼容runtime api的版本，即 nvidia-smi 显示的版本大于nvcc --version 的版本通常不会出现大问题。**

**多版本CUDA切换**

[https://baijiahao.baidu.com/s?id=1663920145053509733&wfr=spider&for=pc&qq-pf-to=pcqq.c2c](https://baijiahao.baidu.com/s?id=1663920145053509733&wfr=spider&for=pc&qq-pf-to=pcqq.c2c)
