---
layout: post
title: "Koding——一个惊艳的在线编程开发平台"
date: 2014-03-01 22:43
comments: true
categories: Technics
tags: Technics Cloud Online Programing
---
<p>最近在v2ex上发现了一个非常酷的云编程发开平台——Koding，与大家分享一下，主要介绍一下它的基本功能和操作。</p>
<h2>What is Koding?</h2>
<p>Koding是一个在线的编程开发平台，致力于简化全球化的合作项目开发，并为每个人提供免费计算和开发资源。它已不仅仅是一个在线的编辑器那么简单，
而是通过提供免费的虚拟机（vm），上面安装了ubuntu操作系统，有真实的终端，允许开发者进行go、nodejs、ruby、python、php、js、C/C++等语言的开发，
可以安装各种工具和应用，。更主要的是，它是完全在线的，可以从世界上的任何地方访问，只需要一个浏览器。不仅如此，他还具有完美的社交功能，
可以和团队成员在线协作。</p>
<center>{% img /images/2014/IMAG2014030101.png %}</center>
<!--more-->

<h2>Activity Feed</h2>
<p>在Koding的<a href="https://koding.com/Activity">Activity面板</a>，是用户间交流的媒介，在这里可以看到一系列的状态更新、代码片段或用户动态。在这里你可以
创建主题，参与某些主题的讨论，可以关注他人，基本的社交功能都一应俱全。</p>

<h2>Development on Koding</h2>
<p>这是Koding的主体部分。在这里你可以像在本地计算机进行开发一样，当然这个可以在线操作，可以实现云同步，随时随地都可以访问，有木有很高大上？
在这里你可以导入自己的GitHub项目，在浏览器中进行项目开发，可以向GitHub push你的项目更新。这里有在线终端，有在线文本编辑器，还有内置浏览器。
除了和在本地编程开发一样的功能以外，还可以自行配置和添加vm，设置自己的独立域名等。下面我们来看看vm的一些硬件参数，主要是cpu、内存、硬盘、网络等。</p>

硬件信息概要，要加sudo使用根权限并输入密码，不加short参数可以查看详细信息
{% codeblock %}
ibillxia@vm-0:~$ sudo lshw -short 
[sudo] password for ibillxia:         
H/W path    Device   Class      Description
===========================================
                     system     Computer
/0                   bus        Motherboard
/0/0                 memory     15GiB System memory
/0/1                 processor  Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
/0/2                 processor  Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
/0/3                 processor  Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
/0/4                 processor  Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
/0/5                 processor  Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
/0/6                 processor  Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
/0/7                 processor  Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
/0/8                 processor  Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
/0/100               bridge     440FX - 82441FX PMC [Natoma]
/0/100/1             bridge     82371SB PIIX3 ISA [Natoma/Triton II]
/0/100/1.1           storage    82371SB PIIX3 IDE [Natoma/Triton II]
/0/100/1.2           bus        82371SB PIIX3 USB [Natoma/Triton II]
/0/100/1.3           bridge     82371AB/EB/MB PIIX4 ACPI
/0/100/2             display    GD 5446
/0/100/3             network    Virtio network device
/0/100/4             storage    Virtio block device
/0/100/5             memory     RAM memory
/1          eth0     network    Ethernet interface
/2          gretap0  network    Ethernet interface
{% endcodeblock %}
查看cpu信息，E5-2630 8核2.30GHz，本文只摘取第1个核的信息 
{% codeblock %}
ibillxia@vm-0:~$ cat /proc/cpuinfo 
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 45
model name      : Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz
stepping        : 7
microcode       : 0x1
cpu MHz         : 2299.998
cache size      : 4096 KB
physical id     : 0
siblings        : 1
core id         : 0
cpu cores       : 1
apicid          : 0
initial apicid  : 0
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl eagerfpu pni pclmulqdq ssse3 cx16 pcid sse4_1 sse4_2 x2apic popcnt aes xsave avx hyperv
isor lahf_lm xsaveopt
bogomips        : 4599.99
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management:
{% endcodeblock %}
查看内存信息，共16GB内存 
{% codeblock %}
ibillxia@vm-0:~$ cat /proc/meminfo                                                                                                                                                                                                                             
MemTotal:       16433708 kB
MemFree:         8506472 kB
Buffers:          332884 kB
Cached:          5334908 kB
SwapCached:            0 kB
Active:          3936496 kB
Inactive:        2222980 kB
Active(anon):    2093920 kB
Inactive(anon):    10856 kB
Active(file):    1842576 kB
Inactive(file):  2212124 kB
Unevictable:        5552 kB
Mlocked:            5552 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:                 0 kB
Writeback:             8 kB
AnonPages:        482832 kB
Mapped:            41668 kB
Shmem:           1623556 kB
Slab:            1522048 kB
SReclaimable:    1225180 kB
SUnreclaim:       296868 kB
KernelStack:        6312 kB
PageTables:        84660 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     8216852 kB
Committed_AS:    5225664 kB
VmallocTotal:   34359738367 kB
VmallocUsed:       45688 kB
VmallocChunk:   34359561000 kB
HardwareCorrupted:     0 kB
AnonHugePages:     18432 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:      245748 kB
DirectMap2M:     7094272 kB
DirectMap1G:     9437184 kB
{% endcodeblock %}
硬盘测速，才219kB/s，不是一般的慢啊
{% codeblock %}
ibillxia@vm-0:~$ dd if=/dev/zero of=test bs=64k count=2k oflag=dsync
2048+0 records in
2048+0 records out
134217728 bytes (134 MB) copied, 612.942 s, 219 kB/s
{% endcodeblock %}
网速测试，一般般
{% codeblock %}
ibillxia@vm-0:~$ ping www.github.com  # 测试1
PING github.com (192.30.252.129) 56(84) bytes of data.
64 bytes from ip1b-lb3-prd.iad.github.com (192.30.252.129): icmp_req=1 ttl=54 time=73.2 ms
64 bytes from ip1b-lb3-prd.iad.github.com (192.30.252.129): icmp_req=2 ttl=54 time=75.9 ms
64 bytes from ip1b-lb3-prd.iad.github.com (192.30.252.129): icmp_req=3 ttl=54 time=72.4 ms
64 bytes from ip1b-lb3-prd.iad.github.com (192.30.252.129): icmp_req=4 ttl=54 time=72.3 ms
64 bytes from ip1b-lb3-prd.iad.github.com (192.30.252.129): icmp_req=5 ttl=54 time=66.2 ms
64 bytes from ip1b-lb3-prd.iad.github.com (192.30.252.129): icmp_req=6 ttl=54 time=66.1 ms
^C
--- github.com ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 5001ms
rtt min/avg/max/mdev = 66.117/71.077/75.947/3.656 ms
ibillxia@vm-0:~$ ping www.stackoverflow.com    # 测试2
PING stackoverflow.com (198.252.206.140) 56(84) bytes of data.
64 bytes from stackoverflow.com (198.252.206.140): icmp_req=1 ttl=49 time=76.1 ms
64 bytes from stackoverflow.com (198.252.206.140): icmp_req=2 ttl=49 time=88.4 ms
64 bytes from stackoverflow.com (198.252.206.140): icmp_req=3 ttl=49 time=75.1 ms
64 bytes from stackoverflow.com (198.252.206.140): icmp_req=4 ttl=49 time=75.1 ms
64 bytes from stackoverflow.com (198.252.206.140): icmp_req=5 ttl=49 time=75.3 ms
64 bytes from stackoverflow.com (198.252.206.140): icmp_req=6 ttl=49 time=82.6 ms
^C
--- stackoverflow.com ping statistics ---
6 packets transmitted, 6 received, 0% packet loss, time 5005ms
rtt min/avg/max/mdev = 75.130/78.813/88.437/5.061 ms
ibillxia@vm-0:~$ ping www.facebook.com     # 测试3
PING star.c10r.facebook.com (31.13.77.81) 56(84) bytes of data.
64 bytes from edge-star-shv-06-sjc1.facebook.com (31.13.77.81): icmp_req=1 ttl=81 time=153 ms
64 bytes from edge-star-shv-06-sjc1.facebook.com (31.13.77.81): icmp_req=2 ttl=81 time=153 ms
64 bytes from edge-star-shv-06-sjc1.facebook.com (31.13.77.81): icmp_req=3 ttl=81 time=153 ms
64 bytes from edge-star-shv-06-sjc1.facebook.com (31.13.77.81): icmp_req=4 ttl=81 time=153 ms
64 bytes from edge-star-shv-06-sjc1.facebook.com (31.13.77.81): icmp_req=5 ttl=81 time=153 ms
^C
--- star.c10r.facebook.com ping statistics ---
6 packets transmitted, 5 received, 16% packet loss, time 5006ms
rtt min/avg/max/mdev = 153.577/153.740/153.951/0.449 ms
{% endcodeblock %}

<p>再来看看一些系统和软件信息。</p>
查看linux内核版本、系统体系结构及预安装软件版本
{% codeblock %}
ibillxia@vm-0:~$ uname -a 
Linux vm-0.ibillxia.koding.kd.io 3.13.0-5-generic #20 SMP Mon Jan 20 19:56:12 PST 2014 x86_64 x86_64 x86_64 GNU/Linux
ibillxia@vm-0:~$ git --version
git version 1.8.1.2
ibillxia@vm-0:~$ mysql --version
mysql  Ver 14.14 Distrib 5.5.32, for debian-linux-gnu (x86_64) using readline 6.2
ibillxia@vm-0:~$ apache2 -v
Server version: Apache/2.2.22 (Ubuntu)
Server built:   Jul 12 2013 13:18:14
{% endcodeblock %}
常用编程语言版本
{% codeblock %}
ibillxia@vm-0:~$ gcc --version
gcc (Ubuntu/Linaro 4.7.3-1ubuntu1) 4.7.3
Copyright (C) 2012 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

ibillxia@vm-0:~$ g++ --version
g++ (Ubuntu/Linaro 4.7.3-1ubuntu1) 4.7.3
Copyright (C) 2012 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

ibillxia@vm-0:~$ java -version
java version "1.7.0_25"
OpenJDK Runtime Environment (IcedTea 2.3.10) (7u25-2.3.10-1ubuntu0.13.04.2)
OpenJDK 64-Bit Server VM (build 23.7-b01, mixed mode)
ibillxia@vm-0:~$ go version  
go version go1.1.1 linux/amd64
ibillxia@vm-0:~$ ruby --version
ruby 1.9.3p194 (2012-04-20 revision 35410) [x86_64-linux]
ibillxia@vm-0:~$ php --version
PHP 5.4.9-4ubuntu2.3 (cli) (built: Sep  4 2013 19:32:25) 
Copyright (c) 1997-2012 The PHP Group
Zend Engine v2.4.0, Copyright (c) 1998-2012 Zend Technologies
ibillxia@vm-0:~$ python --version                                                                                                                                                                                                                                     
Python 2.7.4
ibillxia@vm-0:~$ perl --version
 
This is perl 5, version 14, subversion 2 (v5.14.2) built for x86_64-linux-gnu-thread-multi
(with 80 registered patches, see perl -V for more detail)
 
Copyright 1987-2011, Larry Wall
 
Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.
 
Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.
{% endcodeblock %}

<h2>Installing and Using KDApps</h2>
<p>除了系统已安装的基本应用外，用户还可以在<a href="https://koding.com/Apps">Koding/Apps</a>上选择一些官方的apps安装到自己的vm上。可以
在线绘图、编辑照片等等。</p>

<h2>Online Teamwork</h2>
<p>Koding还具有团退协作功能，你可以创建自己的group或参加到别人的group中。加入到一个team后，系统会分配你一个Session ID，通过这个ID你可以进入
到队友的vm当中，然后你们相互之间都可以看到对方的编码动态。</p>

<p>关于Koding的更多内容，请戳<a href="http://learn.koding.com/getting-started/">Learn Koding</a>。</p>