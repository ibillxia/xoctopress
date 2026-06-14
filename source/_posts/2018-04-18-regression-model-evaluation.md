---   
layout: post   
title: "【Python机器学习】回归模型评估方法总结"   
date: 2018-04-18 15:42   
comments: true   
categories: DataScience   
tags: 机器学习 回归 模型评估   
---   

回归模型评估常用的有四种方法，分别是：平均绝对值误差、均方误差、均方根误差和R平方值，如下表所示：

| 指标 | 描述 | metrics方法 |
| - | - | - |
| Mean Absolute Error(MAE) | 平均绝对误差 | from sklearn.metrics import mean\_absolute\_error |
| Mean Square Error(MSE) | 均方误差 | from sklearn.metrics import mean\_squared\_error |
| Root Mean Square Error(RMSE) | 均方根误差 | from sklearn.metrics import root\_mean\_squared\_error |
| R-Squared | R平方值 | from sklearn.metrics import r2\_score |

<br>
更多评估指标参见 sklearn 官方文档：[sklearn.metrics 文档](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.mean_absolute_error.html).
<!--more-->

## 1.平均绝对误差 MAE

平均绝对误差（MAE）就是指预测值与真实值之间平均相差多大，公式如下：

<center>{% img /images/2018/IMAG2018041801.png %}</center>

<center>图1 平均绝对误差（MAE）</center>

其中，$f_i$ 是预测值，$y_i$ 是真实值，$e_i=|f_i-y_i|$ 即是绝对误差。

sklearn库的metrics模块提供了 mean_absolute_error 方法


## 2.均方误差 MSE

均方误差是指参数估计值与参数真值之差平方的期望值，记为MSE。MSE是衡量平均误差的一种较方便的方法，MSE可以评价数据的变化程度，MSE的值越小，说明预测模型描述实验数据具有更好的精确度。均方误差的公式如下：

<center>{% img /images/2018/IMAG2018041802.svg %}</center>

<center>图2 均方误差</center>

sklearn库的metrics模块提供了 mean_squared_error 方法，用来对回归模型进行均方误差评估


## 3.均方根误差 RMSE

<center>{% img /images/2018/IMAG2018041803.png %}</center>

<center>图3 均方根误差</center>

sklearn库的metrics模块提供了 root_mean_squared_error 方法

关于MAE与RMSE的比较见文章

[https://medium.com/human-in-a-machine-world/mae-and-rmse-which-metric-is-better-e60ac3bde13d](https://medium.com/human-in-a-machine-world/mae-and-rmse-which-metric-is-better-e60ac3bde13d)


## 4.R平方值

它是表征回归方程在多大程度上解释了因变量的变化，或者说方程对观测值的拟合程度如何。其取值在0与1之间，其值越接近1，则变量的解释程度就越高，其值越接近0，其解释程度就越弱。其公式如图4所示：

<center><img style="max-width:500px" src="/images/2018/IMAG2018041804.png"></center>
<center>图4 R平均值</center>

sklearn库的metrics模块提供了r2_score方法，用来对回归模型进行R平方值评估


## 参考链接
[【1】sklearn库的mean_absolute_error方法](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.mean_absolute_error.html)   
[【2】sklearn库的mean_squared_error方法](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.mean_squared_error.html)   
[【3】sklearn库的root_mean_squared_error方法](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.root_mean_squared_error.html)   
[【4】sklearn库的r2_score方法](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.r2_score.html)  
