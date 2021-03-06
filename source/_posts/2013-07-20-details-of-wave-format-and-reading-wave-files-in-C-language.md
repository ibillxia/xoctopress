---
layout: post
title: "PCM WAVE格式详解及用C语言实现wave文件的读取"
date: 2013-07-20 20:07
comments: true
categories: ASSP Program
tags: Speech wave C语言 信号处理
---
<h2>1.PCM Wave格式详解</h2>
<p>WAVE文件格式是微软RIFF(Resource Interchange File Format,资源交换文件标准)的一种，是针对于多媒体文件存储的一种文件格式和标准。
一般而言，RIFF文件由文件头和数据两部分组成，一个WAVE文件由一个“WAVE”数据块组成，这个“WAVE”块又由一个"fmt"子数据块和一个“data”子
数据块组成，也称这种格式为“Canonical form”（权威/牧师格式），如下图所示：
<center>{% img /images/2013/IMAG2013072001.gif %}</center>
</p>
<!--more-->
<p>每个字段的涵义如下：
ChunkID: 占4个字节，内容为“RIFF”的ASCII码(0x52494646)，以大端（big endian）存储。</br>
ChunkSize: 4字节，存储整个文件的字节数（不包含ChunkID和ChunkSize这8个字节），以小端（little endian）方式存储。</br>
Format: 4字节，内容为“WAVE”的ASCII码(0x57415645)，以大端存储。</br>
</p>

<p>
其中bigendian 主要有一个特征，在内存中对操作数的存储方式和从高字节到低字节。例如：0x1234，这样一个数，存储为:</br>
0x4000:   0x12</br>
0x4001:   0x34</br>
而小尾端littleendian是：</br>
0x4000:   0x34</br>
0x4001:   0x12</br>
用程序在区别的话，可以考虑：
``` c
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[])
{
       union w
      {
       short int a;
       char b;
      }c;
      c.a=1;
      if( c.b==1 )  printf("little endian\n");
      else printf("big endian\n");
      system("PAUSE"); 
      return 0;
}
```
</p>

<p>"WAVE"格式由两个子数据块构成：“fmt”块和“data”块，其中“fmt”块的详细解释如下：
Subchunk1ID: 占4个字节，内容为“fmt ”的ASCII码(0x666d7420)，以大端存储。</br>
Subchunk1Size: 占4个字节，存储该子块的字节数（不含前面的Subchunk1ID和Subchunk1Size这8个字节），以小端方式存储。</br>
AudioFormat：占2个字节，以小端方式存储，存储音频文件的编码格式，例如若为PCM则其存储值为1，若为其他非PCM格式的则有一定的压缩。</br>
NumChannels: 占2个字节，以小端方式存储，通道数，单通道(Mono)值为1，双通道(Stereo)值为2，等等。</br>
SampleRate: 占4个字节，以小端方式存储，采样率，如8k，44.1k等。</br>
ByteRate: 占4个字节，以小端方式存储，每秒存储的bit数，其值=SampleRate * NumChannels * BitsPerSample/8</br>
BlockAlign: 占2个字节，以小端方式存储，块对齐大小，其值=NumChannels * BitsPerSample/8</br>
BitsPerSample: 占2个字节，以小端方式存储，每个采样点的bit数，一般为8,16,32等。</br>
接下来是两个可选的扩展参数：</br>
ExtraParamSize: 占2个字节，表示扩展段的大小。</br>
ExtraParams: 扩展段其他自定义的一些参数的具体内容，大小由前一个字段给定。
</p>

<p>其中，对于每个采样点的bit数，不同的bit数读取数据的方式不同：
``` c
// data 为读取到的采样点的值，speech为原始数据流，
//对应于下面的"WAVE"格式文件的第二个子数据块“data”块的“Data”部分。
for(i=0;i<NumSample;i++){
	if(BitsPerSample==8)
		data[i] = (int)*((char*)speech+i);
	else if(BitsPerSample==16)
		data[i] = (int)*((short*)speech+i);
	else if(BitsPerSample==32)
		data[i] = (int)*((int*)speech+i);
}
```
</p>

<p>"WAVE"格式文件的第二个子数据块是“data”，其个字段的详细解释如下：</br>
Subchunk2ID: 占4个字节，内容为“data”的ASCII码(0x64617461)，以大端存储。</br>
Subchunk2Size: 占4个字节，内容为接下来的正式的数据部分的字节数，其值=NumSamples * NumChannels * BitsPerSample/8</br>
Data: 真正的语音数据部分。</br>
</p>

<h2>一个Wave文件头的实例</h2>
<p>设一个wave文件的前72个字节的十六进制内容如下(可以使用Ultra Edit等工具查看wave文件头)：
```
52 49 46 46 24 08 00 00 57 41 56 45 66 6d 74 20 10 00 00 00 01 00 02 00 
22 56 00 00 88 58 01 00 04 00 10 00 64 61 74 61 00 08 00 00 00 00 00 00 
24 17 1e f3 3c 13 3c 14 16 f9 18 f9 34 e7 23 a6 3c f2 24 f2 11 ce 1a 0d 
```
则其个字段的解析如下图：
<center>{% img /images/2013/IMAG2013072002.gif %}</center>
</p>


<h2>C语言实现wave文件的读取</h2>
<p>这里给出一个用基本的C语言文件操作库函数实现的Wave文件读取的实例代码，可以跨Windows和Linux平台。</p>
``` c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// define Wave format structure
typedef struct tWAVEFORMATEX
{
    short wFormatTag;         /* format type */
    short nChannels;          /* number of channels (i.e. mono, stereo...) */
    unsigned int nSamplesPerSec;     /* sample rate */
    unsigned int nAvgBytesPerSec;    /* for buffer estimation */
    short nBlockAlign;        /* block size of data */
    short wBitsPerSample;     /* number of bits per sample of mono data */
    short cbSize;             /* the count in bytes of the size of */
                                    /* extra information (after cbSize) */
} WAVEFORMATEX, *PWAVEFORMATEX;

char* wavread(char *fname, WAVEFORMATEX *wf);

int main(){
	char fname[] = "test.wav";
	char *speech;
	WAVEFORMATEX wf;
	
	speech = wavread(fname, &wf);
	// afterward processing...
	
	return 0;
}

// read wave file
char* wavread(char *fname, WAVEFORMATEX *wf){
	FILE* fp;
	char str[32];
	char *speech;
	unsigned int subchunk1size; // head size
	unsigned int subchunk2size; // speech data size

	// check format type
	fp = fopen(fname,"r");
	if(!fp){
		fprintf(stderr,"Can not open the wave file: %s.\n",fname);
		return NULL;
	}
	fseek(fp, 8, SEEK_SET);
	fread(str, sizeof(char), 7, fp);
	str[7] = '\0';
	if(strcmp(str,"WAVEfmt")){
		fprintf(stderr,"The file is not in WAVE format!\n");
		return NULL;
	}
	
	// read format header
	fseek(fp, 16, SEEK_SET);
	fread((unsigned int*)(&subchunk1size),4,1,fp);
	fseek(fp, 20, SEEK_SET);
	fread(wf, subchunk1size, 1, fp);
	
	// read wave data
	fseek(fp, 20+subchunk1size, SEEK_SET);
	fread(str, 1, 4, fp);
	str[4] = '\0';
	if(strcmp(str,"data")){
		fprintf(stderr,"Locating data start point failed!\n");
		return NULL;
	}
	fseek(fp, 20+subchunk1size+4, SEEK_SET);
	fread((unsigned int*)(&subchunk2size), 4, 1, fp);
	speech = (char*)malloc(sizeof(char)*subchunk2size);
	if(!speech){
		fprintf(stderr, "Memory alloc failed!\n");
		return NULL;
	}
	fseek(fp, 20+subchunk1size+8, SEEK_SET);
	fread(speech, 1, subchunk2size, fp);

	fclose(fp);
	return speech;
}
```

<h2>参考</h2>
<p>
[1]WAVE PCM soundfile format: https://ccrma.stanford.edu/courses/422/projects/WaveFormat/ </br>
[2]Resource Interchange File Format: http://en.wikipedia.org/wiki/Resource_Interchange_File_Format </br>
[3]基于Visual C++6.0的声音文件操作: http://www.yesky.com/20030414/1663116_1.shtml
</p>
