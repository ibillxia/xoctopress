---
layout: post
title: "伪造IP地址的原理"
date: 2010-08-31 09:41
comments: true
categories: Technics
tags: IP
---
<p>入侵者使用假IP地址发送包，利用基于IP地址证实的应用程序。其结果是未授权的远端用户进入带有防火墙的主机系统。</p>

<p>假设有两台主机A、B和入侵者控制的主机X。假设B授予A某些特权，使得A能够获得B所执行的一些操作。X的目标就是得到与B相同的权利。
为了实现该目标，X必须执行两步操作：首先，与B建立一个虚假连接；然后，阻止A向B报告网络证实系统的问题。主机X必须假造A的IP地址，
从而使B相信从X发来的包的确是从A发来的。</p>

<p>我们同时假设主机A和B之间的通信遵守TCP／IP的三次握手机制。握手方法是：</p>
{% codeblock %}
A->：SYN（序列号=M）
B->A：SYN（序列号＝N），ACK（应答序号=M+1）
A->B：ACK（应答序号＝N+1）
{% endcodeblock %}
<!--more-->
<p>主机X伪造IP地址步骤如下：首先，X冒充A，向主机B发送一个带有随机序列号的SYN包。主机B响应，向主机A发送一个带有应答号的SYN+ACK包、
该应答号等于原序列号加1。同时，主机B产生自己发送包序列号，并将其与应答号一起发送。为了完成三次握手，主机X需要向主</p>

<p>机B回送一个应答包，其应答号等于主机B向主机A发送的包序列号加1。假设主机X与A和B不同在一个子网内，则不能检测到B的包，
主机X只有算出B的序列号，才能创建TCP连接。其过程描述如下：</p>
{% codeblock %}
X->B：SYN（序列号=M），SRC=A
B->A：SYN（序列号=N），ACK（应答号=M+1）
X->B：ACK（应答号＝N+1），SRC＝A
{% endcodeblock %}

<p>同时，主机X应该阻止主机A响应主机B的包。为此，X可以等到主机A因某种原因终止运行，或者阻塞主机A的操作系统协议部分，使它不能响应主机B。
一旦主机X完成了以上操作，它就可以向主机B发送命令。主机B将执行这些命令，认为他们是由合法主机A发来的。</p>