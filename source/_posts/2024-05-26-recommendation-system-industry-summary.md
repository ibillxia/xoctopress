---   
layout: post   
title: "工业界推荐系统技术要点总结"   
date: 2024-05-26 11:25   
comments: true   
categories: RecSys   
tags: 推荐系统 深度学习 工程实践   
---   

原文链接：[https://zhuanlan.zhihu.com/p/689894486](https://zhuanlan.zhihu.com/p/689894486)

工业界的推荐系统技术要点有很多，想从事推荐系统相关方向的同学都建议刷一刷。

# 多目标排序模型

回顾一下推荐系统的链路

<center>{% img /images/2024/IMAG2024052601.jpg %}</center>

<!--more-->

常见的交互指标

<center>{% img /images/2024/IMAG2024052602.jpg %}</center>

排序模型做的事情

<center>{% img /images/2024/IMAG2024052603.jpg %}</center>

多目标模型就是要预测多个目标

<center>{% img /images/2024/IMAG2024052604.jpg %}</center>

预测概率和实际是否交互求交叉熵损失

<center>{% img /images/2024/IMAG2024052605.jpg %}</center>

训练时通常会遇到类别不平衡问题，可以考虑做采样

<center>{% img /images/2024/IMAG2024052606.jpg %}</center>

采样可能导致预估点击率偏高

<center>{% img /images/2024/IMAG2024052607.jpg %}</center>

可以通过校准公式进行校准

<center>{% img /images/2024/IMAG2024052608.jpg %}</center>

Multi-gate Mixture-of-Experts

几个专家就是放几个神经网络

<center>{% img /images/2024/IMAG2024052609.jpg %}</center>

进一步考虑对多个神经网络的输出进行加权

<center>{% img /images/2024/IMAG2024052610.jpg %}</center>

<center>{% img /images/2024/IMAG2024052611.jpg %}</center>

可能会出现极化的现象

<center>{% img /images/2024/IMAG2024052612.jpg %}</center>

可以通过dropout的方式来解决极化

<center>{% img /images/2024/IMAG2024052613.jpg %}</center>

多目标有多个预估分数就可以有不同融合方式

<center>{% img /images/2024/IMAG2024052614.jpg %}</center>

<center>{% img /images/2024/IMAG2024052615.jpg %}</center>

<center>{% img /images/2024/IMAG2024052616.jpg %}</center>

<center>{% img /images/2024/IMAG2024052617.jpg %}</center>

视频播放建模

<center>{% img /images/2024/IMAG2024052618.jpg %}</center>

播放时长建模

<center>{% img /images/2024/IMAG2024052619.jpg %}</center>

<center>{% img /images/2024/IMAG2024052620.jpg %}</center>

视频完播用回归或分类都可以

<center>{% img /images/2024/IMAG2024052621.jpg %}</center>

<center>{% img /images/2024/IMAG2024052622.jpg %}</center>

完播率通常和视频时长有关，不能直接把预估的完播率⽤到融分公式

<center>{% img /images/2024/IMAG2024052623.jpg %}</center>

通常做个调整再用到融分公式

<center>{% img /images/2024/IMAG2024052624.jpg %}</center>

# 排序模型的特征

用户画像

<center>{% img /images/2024/IMAG2024052625.jpg %}</center>

物品画像

<center>{% img /images/2024/IMAG2024052626.jpg %}</center>

用户统计特征

<center>{% img /images/2024/IMAG2024052627.jpg %}</center>

笔记统计特征

<center>{% img /images/2024/IMAG2024052628.jpg %}</center>

场景特征

<center>{% img /images/2024/IMAG2024052629.jpg %}</center>

特征处理

<center>{% img /images/2024/IMAG2024052630.jpg %}</center>

特征覆盖率的概念

<center>{% img /images/2024/IMAG2024052631.jpg %}</center>

数据服务分三步

<center>{% img /images/2024/IMAG2024052632.jpg %}</center>

<center>{% img /images/2024/IMAG2024052633.jpg %}</center>

<center>{% img /images/2024/IMAG2024052634.jpg %}</center>

# 粗排

精排模型的线上推理代价大

<center>{% img /images/2024/IMAG2024052635.jpg %}</center>

双塔模型牺牲准确性换计算量

<center>{% img /images/2024/IMAG2024052636.jpg %}</center>

粗排的三塔模型

<center>{% img /images/2024/IMAG2024052637.jpg %}</center>

<center>{% img /images/2024/IMAG2024052638.jpg %}</center>

三塔模型的推理

<center>{% img /images/2024/IMAG2024052639.jpg %}</center>
