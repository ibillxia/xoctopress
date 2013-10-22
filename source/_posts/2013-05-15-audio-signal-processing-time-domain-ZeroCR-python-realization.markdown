---
layout: post
title: "语音信号处理之时域分析-过零率及其Python实现"
date: 2013-05-15 21:44
comments: true
categories: ASSP
tags: ZCR Python
---
<h2>过零率（Zero Crossing Rate）</h2>
<p>概念：过零率（Zero Crossing Rate，ZCR）是指在每帧中，语音信号通过零点（从正变为负或从负变为正）的次数。
这个特征已在语音识别和音乐信息检索领域得到广泛使用，是对敲击的声音的分类的关键特征。</p>

<p>ZCR的数学形式化定义为：
<center>$zcr = \frac{1}{T-1}\sum_{t=1}^{T-1}\pi\{s_{t}s_{t-1}<0\}$.</center>
其中$s$是采样点的值，$T$为帧长，函数$\pi\{A\}$在A为真是值为1，否则为0.
</p>

<p>特性：</br>
(1).一般而言，清音（unvoiced sound）和环境噪音的ZCR都大于浊音（voiced sound）；</br>
(2).由于清音和环境噪音的ZCR大小相近，因而不能够通过ZCR来区分它们；</br>
(3).在实际当中，过零率经常与短时能量特性相结合来进行端点检测，尤其是ZCR用来检测清音的起止点；</br>
(4).有时也可以用ZCR来进行粗略的基频估算，但这是非常不可靠的，除非有后续的修正（refine）处理过程。
</p>

<!--more-->

<h2>ZCR的Python实现</h2>
<p>ZCR的Python实现如下：
{% codeblock %}
import math
import numpy as np

def ZeroCR(waveData,frameSize,overLap):
    wlen = len(waveData)
    step = frameSize - overLap
    frameNum = math.ceil(wlen/step)
    zcr = np.zeros((frameNum,1))
    for i in range(frameNum):
        curFrame = waveData[np.arange(i*step,min(i*step+frameSize,wlen))]
        #To avoid DC bias, usually we need to perform mean subtraction on each frame
        #ref: http://neural.cs.nthu.edu.tw/jang/books/audiosignalprocessing/basicFeatureZeroCrossingRate.asp
        curFrame = curFrame - np.mean(curFrame) # zero-justified
        zcr[i] = sum(curFrame[0:-1]*curFrame[1::]<=0)
    return zcr
{% endcodeblock %}
</p>

<p>对于给定语音文件aeiou.wav，利用上面的函数计算ZCR的代码如下：
{% codeblock %}
import math
import wave
import numpy as np
import pylab as pl

# ============ test the algorithm =============
# read wave file and get parameters.
fw = wave.open('aeiou.wav','rb')
params = fw.getparams()
print(params)
nchannels, sampwidth, framerate, nframes = params[:4]
str_data = fw.readframes(nframes)
wave_data = np.fromstring(str_data, dtype=np.short)
wave_data.shape = -1, 1
#wave_data = wave_data.T
fw.close()

# calculate Zero Cross Rate
frameSize = 256
overLap = 0
zcr = ZeroCR(wave_data,frameSize,overLap)

# plot the wave
time = np.arange(0, len(wave_data)) * (1.0 / framerate)
time2 = np.arange(0, len(zcr)) * (len(wave_data)/len(zcr) / framerate)
pl.subplot(211)
pl.plot(time, wave_data)
pl.ylabel("Amplitude")
pl.subplot(212)
pl.plot(time2, zcr)
pl.ylabel("ZCR")
pl.xlabel("time (seconds)")
pl.show()
{% endcodeblock %}
</p>

<p>运行以上程序得到下图：
<center>{% img /images/2013/IMAG2013051502.png %}</center>
</p>

<h2>参考（References）</h2>
<p>
[1]Zero Crossing Rate (過零率): http://neural.cs.nthu.edu.tw/jang/books/audiosignalprocessing/basicFeatureZeroCrossingRate.asp?title=5-3%20Zero%20Crossing%20Rate%20(%B9L%B9s%B2v)&language=english</br>
[2]Wiki: http://zh.wikipedia.org/zh/过零率
</p>
