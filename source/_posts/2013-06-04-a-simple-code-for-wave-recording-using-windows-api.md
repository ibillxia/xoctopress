---
layout: post
title: "用Windows API实现一个简单的录音程序"
date: 2013-06-04 23:59
comments: true
categories: ASSP Program
tags: Speech 信号处理 wave
---
<p>本文介绍如何使用Windows API来录制语音信号兵保存到wave文件中，主要用到三个结构体和几个wave开头的API函数（在Winmm.lib文件中）。其中三个结构体是WAVEFORMATEX、WAVEHDR、MMTIME，其详细定义都在MMSystem.h中定义，
可以转到定义看其详细内容及每一项的英文注释。用到的API函数的详细用法可以参见MSDN： http://msdn.microsoft.com/en-us/library/windows/desktop/dd743847(v=vs.85).aspx
详细的使用过程请看下文的源代码，这是一个Win32 Application，需要手动添加Winmm.lib的依赖。</p>

<!--more-->

<p>实例程序</p>
``` c
// ******************* FileName: WinMain.cpp *****************************
// 该源程序需要加入到 VC6 的 Win32 Application 的 empty Project 中
// 对于工程的 Link 选项，至少要包含以下库: msvcrt.lib Winmm.lib

#include <stdio.h>
#include <atlstr.h>
#include <windows.h>
#include <Mmsystem.h>

#pragma comment(lib,"Winmm.lib")

char lpTemp[256];

DWORD FCC(LPSTR lpStr)
{
	DWORD Number = lpStr[0] + lpStr[1] *0x100 + lpStr[2] *0x10000 + lpStr[3] *0x1000000 ;
	return Number;
}

int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow )
{
	DWORD datasize = 48000;
	  
	// 设置录音采样参数
	WAVEFORMATEX waveformat;
	waveformat.wFormatTag=WAVE_FORMAT_PCM; // 指定录音格式
	waveformat.nChannels=1;
	waveformat.nSamplesPerSec=8000;
	waveformat.nBlockAlign=1;
	waveformat.wBitsPerSample=8;
	waveformat.cbSize=0;
	waveformat.nAvgBytesPerSec=waveformat.nChannels*waveformat.nSamplesPerSec*waveformat.wBitsPerSample/8;
	
	sprintf(lpTemp,"WAVEFORMATEX size = %lu", sizeof(WAVEFORMATEX));
	MessageBox(NULL,CString(lpTemp),CString("提示"),MB_OK);

	HWAVEIN m_hWaveIn;
	if ( !waveInGetNumDevs() )
	{
		MessageBox(NULL,CString("没有可以使用的 WaveIn 通道"),CString("提示"),MB_OK);
		return 0;
	}

	// 打开录音设备
	int res = waveInOpen(&m_hWaveIn,WAVE_MAPPER, &waveformat, (DWORD)NULL,0L,CALLBACK_WINDOW); 
	if ( res != MMSYSERR_NOERROR )
	{
	   sprintf(lpTemp, "打开 waveIn 通道失败，Error_Code = 0x%x", res );
	   MessageBox(NULL,CString(lpTemp),CString("提示"),MB_OK);
	   return 0;
	}
	
	WAVEHDR m_pWaveHdr;
	m_pWaveHdr.lpData = (char *)GlobalLock( GlobalAlloc(GMEM_MOVEABLE|GMEM_SHARE, datasize) );
	memset(m_pWaveHdr.lpData, 0, datasize );
	m_pWaveHdr.dwBufferLength = datasize;
	m_pWaveHdr.dwBytesRecorded = 0;
	m_pWaveHdr.dwUser = 0;
	m_pWaveHdr.dwFlags = 0;
	m_pWaveHdr.dwLoops = 0;
	sprintf( lpTemp, "WAVEHDR size = %lu", sizeof(WAVEHDR) );
	MessageBox(NULL,CString(lpTemp),CString("提示"),MB_OK);

	// 准备内存块录音
	int resPrepare = waveInPrepareHeader( m_hWaveIn, &m_pWaveHdr, sizeof(WAVEHDR) ); 
	if ( resPrepare != MMSYSERR_NOERROR) 
	{
		sprintf(lpTemp, "不能开辟录音头文件，Error_Code = 0x%03X", resPrepare );
		MessageBox(NULL,CString(lpTemp),CString("提示"),MB_OK);
		return 0;
	}

	resPrepare = waveInAddBuffer( m_hWaveIn, &m_pWaveHdr, sizeof(WAVEHDR) );
	if ( resPrepare != MMSYSERR_NOERROR) 
	{
		sprintf(lpTemp, "不能开辟录音用缓冲，Error_Code = 0x%03X", resPrepare );
		MessageBox(NULL,CString(lpTemp),CString("提示"),MB_OK);
		return 0;
	}
 
	if (! waveInStart(m_hWaveIn) ) 
	{
		MessageBox(NULL,CString("开始录音"),CString("提示"),MB_OK);
	}
	else 
	{
		MessageBox(NULL,CString("开始录音失败"),CString("提示"),MB_OK);
		return 0;
	}
	Sleep(30000);

	MMTIME mmt;
	mmt.wType = TIME_BYTES;
	sprintf( lpTemp, "sizeof(MMTIME) = %d, sizeof(UINT) = %d", sizeof(MMTIME), sizeof(UINT) );
	MessageBox(NULL,CString(lpTemp),CString("提示"),MB_OK);

	if (! waveInGetPosition(m_hWaveIn, &mmt, sizeof(MMTIME)) )
	{
		MessageBox(NULL,CString("取得现在音频位置"),CString("提示"),MB_OK);
	}
	else 
	{
		MessageBox(NULL,CString("不能取得音频长度"),CString("提示"),MB_OK);
		return 0;
	}

	if (mmt.wType != TIME_BYTES) 
	{
		MessageBox(NULL,CString("指定的 TIME_BYTES 格式音频长度不支持"),CString("提示"),MB_OK);
		return 0;
	}

	if (! waveInStop(m_hWaveIn) ) 
	{
		MessageBox(NULL,CString("停止录音"),CString("提示"),MB_OK);
	}
	else  
	{
		MessageBox(NULL,CString("停止录音失败"),CString("提示"),MB_OK);
	}
	
	if ( waveInReset(m_hWaveIn) ) 
	{
		MessageBox(NULL,CString("重置内存区失败"),CString("提示"),MB_OK);
		return 0;
	}

	m_pWaveHdr.dwBytesRecorded = mmt.u.cb;
	DWORD NumToWrite=0;
	DWORD dwNumber = 0;
	HANDLE FileHandle = CreateFile( CString("myTest.wav"), GENERIC_WRITE, 
		FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);

	// memset(m_pWaveHdr.lpData, 0, datasize);
	dwNumber = FCC("RIFF");
	WriteFile(FileHandle, &dwNumber, 4, &NumToWrite, NULL);
	dwNumber = m_pWaveHdr.dwBytesRecorded + 18 + 20;
	WriteFile(FileHandle, &dwNumber, 4, &NumToWrite, NULL);
	dwNumber = FCC("WAVE");
	WriteFile(FileHandle, &dwNumber, 4, &NumToWrite, NULL);
	dwNumber = FCC("fmt ");
	WriteFile(FileHandle, &dwNumber, 4, &NumToWrite, NULL);
	dwNumber = 18L;
	WriteFile(FileHandle, &dwNumber, 4, &NumToWrite, NULL);
	WriteFile(FileHandle, &waveformat, sizeof(WAVEFORMATEX), &NumToWrite, NULL);
	dwNumber = FCC("data");
	WriteFile(FileHandle, &dwNumber, 4, &NumToWrite, NULL);
	dwNumber = m_pWaveHdr.dwBytesRecorded;
	WriteFile(FileHandle, &dwNumber, 4, &NumToWrite, NULL);
	WriteFile(FileHandle, m_pWaveHdr.lpData, m_pWaveHdr.dwBytesRecorded, &NumToWrite, NULL);
	SetEndOfFile(FileHandle);
	CloseHandle( FileHandle );  
	FileHandle = INVALID_HANDLE_VALUE; // 收尾关闭句柄
	MessageBox(NULL,CString("应该已生成 myTest.wav 文件"),CString("提示"),MB_OK);

	if ( waveInUnprepareHeader(m_hWaveIn, &m_pWaveHdr, sizeof(WAVEHDR)) ) 
	{
		MessageBox(NULL,CString("Un_Prepare Header 失败"),CString("提示"),MB_OK);
	}
	else 
	{
		MessageBox(NULL,CString("Un_Prepare Header 成功"),CString("提示"),MB_OK);
		return 0;
	}

	if ( GlobalFree(GlobalHandle( m_pWaveHdr.lpData )) ) 
	{
		MessageBox(NULL,CString("Global Free 失败"),CString("提示"),MB_OK);
	}
	else 
	{
		MessageBox(NULL,CString("Global Free 成功"),CString("提示"),MB_OK);
		return 0;
	}

	if (res == MMSYSERR_NOERROR ) // 关闭录音设备
	{
		if (waveInClose(m_hWaveIn)==MMSYSERR_NOERROR)
		{
			MessageBox(NULL,CString("正常关闭录音设备"),CString("提示"),MB_OK);
		}
		else
		{
			MessageBox(NULL,CString("非正常关闭录音设备"),CString("提示"),MB_OK);
			return 0;
		}
	}

	return 0;
}
// ******************* End of File ************************
```

<p>这里提供的代码有点杂乱，现已整理成一个小的接口，并提供了一个简单的示例，放在GitHub上：https://github.com/ibillxia/Demo/tree/master/DemoSpeechRecord</p>

<p>参考：</br>
[1]MSDN: http://msdn.microsoft.com/en-us/library/windows/desktop/dd743586(v=vs.85).aspx</br>
[2]基于API的录音机程序: http://www.vckbase.com/index.php/wv/664
</p>
