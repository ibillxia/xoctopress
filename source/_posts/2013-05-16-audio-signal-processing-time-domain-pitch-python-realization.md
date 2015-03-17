---
layout: post
title: "语音信号处理之时域分析-音高及其Python实现"
date: 2013-05-16 23:10
comments: true
categories: ASSP
tags: Speech Python 信号处理 音高
---
<h2>音高（Pitch）</h2>
<p>概念：音高（Pitch）是语音信号的一个很重要的特征，直觉上而言它表示声音频率的高低，这个频率是指基本频率（基频），也即基本周期的倒数。
若直接观察语音的波形，只要语音信号稳定，我们可以很容易的看出基本周期的存在。例如我们取一个包含256个采样点的帧，单独绘制波形图，就可以明显的
看到它的基本周期。如下图所示：
<center>{% img /images/2013/IMAG2013051601.png %}</center>
其中最上面的波形为|a|的发音，中间的为上图中红色双竖线（位于语音区）所对应的帧的具体波形，而最下面的是上图中绿色双竖线（位于静音区）所
对应的帧的具体波形。很容易看到中间的波形具有明显的周期性。
</p>
<!--more-->
<p>其代码如下：
``` py3
import wave
import numpy as np
import pylab as pl

# ============ test the algorithm =============
# read wave file and get parameters.
fw = wave.open('a.wav','rb')
params = fw.getparams()
print(params)
nchannels, sampwidth, framerate, nframes = params[:4]
strData = fw.readframes(nframes)
waveData = np.fromstring(strData, dtype=np.int16)
waveData = waveData*1.0/max(abs(waveData))  # normalization
fw.close()

# plot the wave
time = np.arange(0, len(waveData)) * (1.0 / framerate)

index1 = 10000.0 / framerate
index2 = 10512.0 / framerate
index3 = 15000.0 / framerate
index4 = 15512.0 / framerate

pl.subplot(311)
pl.plot(time, waveData)
pl.plot([index1,index1],[-1,1],'r')
pl.plot([index2,index2],[-1,1],'r')
pl.plot([index3,index3],[-1,1],'g')
pl.plot([index4,index4],[-1,1],'g')
pl.xlabel("time (seconds)")
pl.ylabel("Amplitude")

pl.subplot(312)
pl.plot(np.arange(512),waveData[10000:10512],'r')
pl.plot([59,59],[-1,1],'b')
pl.plot([169,169],[-1,1],'b')
print(1/( (169-59)*1.0/framerate ))
pl.xlabel("index in 1 frame")
pl.ylabel("Amplitude")

pl.subplot(313)
pl.plot(np.arange(512),waveData[15000:15512],'g')
pl.xlabel("index in 1 frame")
pl.ylabel("Amplitude")
pl.show()
```
</p>

<p>根据参考[1]，可以通过观察一帧的波形图来计算基音频率（感觉这种方法有点奇葩，不过很直观。例如这里的基频为：1/( (169-59)*1.0/framerate )=145.45Hz），
然后还可以计算半音（semitone，可以参见[2]），进而得到pitch与semitone的关系。[1]中还提到了钢琴的半音差，DS表示完全看不懂啊，有木有！！！</p>

<p>参考[2]中还简单介绍了如何改变音高、扩展音域，以及如何改变乐器的振动的弦的音高（通过改变弦长、张力、密度等），感兴趣的可以看看。</p>

<p>另外，由于生理结构的差异，男女性的音高范围不尽相同，一般而言：</br>
·男性的音高范围是35~72半音，对应的频率范围是62~523Hz；</br>
·女性的音高范围是45~83半音，对应的频率范围是110~1000Hz。</br>
然而，我们分辨男女的声音并不是只根据音高，还要根据音色（也即共振峰，下一篇文章中将详细介绍）。
</p>

<p>关于音高的计算，目前有很多种算法，具体将会在后续文章中详细介绍。</p>

<h2>参考（References）</h2>
<p>
[1]Pitch (音高): http://neural.cs.nthu.edu.tw/jang/books/audiosignalprocessing/basicFeaturePitch.asp</br>
[2]Wiki： http://zh.wikipedia.org/wiki/音高
</p>
