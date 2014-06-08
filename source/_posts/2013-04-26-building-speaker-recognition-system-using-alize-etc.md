---
layout: post
title: "使用Alize等工具构建说话人识别平台"
date: 2013-04-26 22:07
comments: true
categories: ASSP
tags: Alize SPro VPR
---
前段时间有好几位同学询问如何用Alize实现说话人识别的问题，由于寒假前赶Paper，来不及详细解答，更没时间写Demo。
开学后不久抽时间写了一个Demo，并上传到了GitHub：[VoicePrintReco-branch-master](https://github.com/ibillxia/VoicePrintReco/tree/master/Demo).

下面将利用Alize+SPro进行简单的GMM-Based的说话人识别的基本流程总结如下：  
#### 1.Features extraction 特征提取  
sfbcep.exe（MFCC）或slpcep.exe（LPCC）  

#### 2.Silence removal 静音检测和去除  
NormFeat.exe 先能量规整  
EnergyDetector.exe 基于能量检测的静音去除  

#### 3.Features Normalization 特征规整  
NormFeat.exe 再使用这个工具进行特征规整</br>

#### 4.World model training  
TrainWorld.exe 训练UBM</br>

#### 5.Target model training  
TrainWorld.exe 在训练好UBM的基础上训练training set和testing set的GMM</br>

#### 6.Testing  
ComputeTest.exe 将testing set 的GMM在training set的GMM上进行测试和打分</br>

#### 7.Score Normalization  
ComputeNorm.exe 将得分进行规整</br>

#### 8. Compute EER 计算等错误率  
你可以查查计算EER的matlab代码，NIST SRE的官网上有下载[DETware_v2.1.tar.gz](http://www.itl.nist.gov/iad/mig//tools/DETware_v2.1.targz.htm) 。  

<!-- more -->

关于各步骤中参数的问题，可以在命令行“工具 -help”来查看该工具个参数的具体含义，另外还可参考Alize源码中各个工具的test目录中提供的实例，
而关于每个工具的作用及理论知识则需要查看相关论文。  

常见问题及解答: http://mistral.univ-avignon.fr/mediawiki/index.php/Frequently_asked_questions  

更多问题请在Google论坛（https://groups.google.com/forum/?fromgroups=&hl=zh-CN#!forum/alize---voice-print-recognition）提出，大家一起讨论！  

### 推荐资料
[1] ALIZE - User Manual: [userguide_alize.001.pdf](http://mistral.univ-avignon.fr/doc/userguide_alize.001.pdf)  
[2] LIA_SPKDET Package documentation: [userguide_LIA_SpkDet.002.pdf](http://mistral.univ-avignon.fr/doc/userguide_LIA_SpkDet.002.pdf)  
[3] [Reference System based on speech modality ALIZE/LIA RAL](http://www-clips.imag.fr/geod/User/laurent.besacier/NEW-TPs/TP-Biometrie/tools/CommentsLBInstall/doc.pdf)
[4] Jean-Francois Bonastre, etc. ALIZE/SpkDet: a state-of-the-art open source software for speaker recognition  
[5] TOMMIE GANNERT. A Speaker Veri?cation System Under The Scope: Alize  
[6] [Alize Wiki](http://mistral.univ-avignon.fr/mediawiki/index.php/Main_Page)  
