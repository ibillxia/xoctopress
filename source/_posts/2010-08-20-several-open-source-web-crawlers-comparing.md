---
layout: post
title: "开源网络爬虫介绍及其比较"
date: 2010-08-20 18:53
comments: true
categories: Technics
tags: 网络爬虫
---
<h2>主流的爬虫</h2>
<p><strong>Nutch</strong></br>
开发语言：Java</br>
主页：<a href="http://lucene.apache.org/nutch/">http://lucene.apache.org/nutch/</a></br>
简介：</br>
Apache的子项目之一，属于Lucene项目下的子项目。</br>
Nutch是一个基于Lucene，类似Google的完整网络搜索引擎解决方案，基于Hadoop的分布式处理模型保证了系统的性能，类似Eclipse的插件机制
保证了系统的可客户化，而且很容易集成到自己的应用之中。
</p>
<!--more-->
<p><strong>Larbin</strong></br>
开发语言：C++</br>
主页：<a href="http://larbin.sourceforge.net/index-eng.html">http://larbin.sourceforge.net</a></br>
简介：</br>
larbin是一种开源的网络爬虫/网络蜘蛛，由法国的年轻人 Sébastien Ailleret独立开发。larbin目的是能够跟踪页面的url进行扩展的抓取，
最后为搜索引擎提供广泛的数据来源。</br>
Larbin只是一个爬虫，也就是说larbin只抓取网页，至于如何parse的事情则由用户自己完成。另外，如何存储到数据库以及建立索引的事情 larbin也不提供。</br>

latbin最初的设计也是依据设计简单但是高度可配置性的原则，因此我们可以看到，一个简单的larbin的爬虫可以每天获取５００万的网页，非常高效。
</p>

<p><strong>Heritrix</strong></br>
开发语言：Java</br>
主页：<a href="http://crawler.archive.org/">http://crawler.archive.org/</a></br>
与Nutch比较：</br>
二者均为Java开源框架，Heritrix是 SourceForge上的开源产品，Nutch为Apache的一个子项目，它们都称作网络爬虫/蜘蛛（ Web Crawler），
它们实现的原理基本一致：深度遍历网站的资源，将这些资源抓取到本地，使用的方法都是分析网站每一个有效的URI，并提交Http请求，
从而获得相应结果，生成本地文件及相应的日志信息等。</br>
Heritrix 是个 "archival crawler" -- 用来获取完整的、精确的、站点内容的深度复制。包括获取图像以及其他非文本内容。抓取并存储相关的内容。
对内容来者不拒，不对页面进行内容上的修改。重新爬行对相同的URL不针对先前的进行替换。爬虫通过Web用户界面启动、监控、调整，允许弹性的
定义要获取的URL。</br></br>
二者的差异：</br>
Nutch 只获取并保存可索引的内容。Heritrix则是照单全收。力求保存页面原貌。</br>
Nutch 可以修剪内容，或者对内容格式进行转换。</br>
Nutch 保存内容为数据库优化格式便于以后索引；刷新替换旧的内容。而Heritrix 是添加(追加)新的内容。</br>
Nutch 从命令行运行、控制。Heritrix 有 Web 控制管理界面。</br>
Nutch 的定制能力不够强，不过现在已经有了一定改进。Heritrix 可控制的参数更多。</br>
Heritrix提供的功能没有nutch多，有点整站下载的味道。既没有索引又没有解析，甚至对于重复爬取URL都处理不是很好。</br>
Heritrix的功能强大，但是配置起来却有点麻烦。
</p>

<h2>其他的爬虫</h2>
<p><strong>WebLech</strong></br>
<a href="http://weblech.sourceforge.net/">http://weblech.sourceforge.net/</a></br>
WebLech是一个功能强大的Web站点下载与镜像工具。它支持按功能需求来下载web站点并能够尽可能模仿标准Web浏览器的行为。
WebLech有一个功能控制台并采用多线程操作。
</p>

<p><strong>Arale</strong></br>
<a href="http://web.tiscali.it/_flat/arale.jsp.html">http://web.tiscali.it/_flat/arale.jsp.html</a></br>
Arale主要为个人使用而设计，而没有像其它爬虫一样是关注于页面索引。Arale能够下载整个web站点或来自web站点的某些资源。
Arale还能够把动态页面映射成静态页面。
</p>

<p><strong>J-Spider</strong></br>
<a href="http://j-spider.sourceforge.net/">http://j-spider.sourceforge.net/</a></br>
J-Spider:是一个完全可配置和定制的Web Spider引擎.你可以利用它来检查网站的错误(内在的服务器错误等),网站内外部链接检查，
分析网站的结构(可创建一个网站地图),下载整个Web站点，你还可以写一个JSpider插件来扩展你所需要的功能。
</p>

<p><strong>Spindle</strong></br>
<a href="http://www.bitmechanic.com/projects/spindle/">http://www.bitmechanic.com/projects/spindle/</a></br>
spindle 是一个构建在Lucene工具包之上的Web索引/搜索工具.它包括一个用于创建索引的HTTP spider和一个用于搜索这些索引的搜索类。
spindle项目提供了一组JSP标签库使得那些基于JSP的站点不需要开发任何Java类就能够增加搜索功能。
</p>

<p><strong>Arachnid</strong></br>
<a href="http://arachnid.sourceforge.net/">http://arachnid.sourceforge.net/</a></br>
Arachnid: 是一个基于Java的web spider框架.它包含一个简单的HTML剖析器能够分析包含HTML内容的输入流.通过实现Arachnid的子类就能够
开发一个简单的Web spiders并能够在Web站上的每个页面被解析之后增加几行代码调用。 Arachnid的下载包中包含两个spider应用程序例子
用于演示如何使用该框架。
</p>

<p><strong>LARM</strong></br>
<a href="http://larm.sourceforge.net/">http://larm.sourceforge.net/</a></br>
LARM能够为Jakarta Lucene搜索引擎框架的用户提供一个纯Java的搜索解决方案。它包含能够为文件，数据库表格建立索引的方法和为Web站点建索引的爬虫。
</p>

<p><strong>JoBo</strong></br>
<a href="http://www.matuschek.net/software/jobo/index.html">http://www.matuschek.net/software/jobo/index.html</a></br>
JoBo 是一个用于下载整个Web站点的简单工具。它本质是一个Web Spider。与其它下载工具相比较它的主要优势是能够自动填充form(如：自动登录)和
使用cookies来处理session。JoBo还有灵活的下载规则(如：通过网页的URL，大小，MIME类型等)来限制下载。
</p>

<p><strong>snoics-reptile</strong></br>
<a href="http://www.blogjava.net/snoics">http://www.blogjava.net/snoics</a></br>
snoics -reptile是用纯Java开发的，用来进行网站镜像抓取的工具，可以使用配制文件中提供的URL入口，把这个网站所有的能用浏览器通过GET的方式
获取到的资源全部抓取到本地，包括网页和各种类型的文件，如：图片、flash、mp3、zip、rar、exe等文件。可以将整个网站完整地下传至硬盘内，
并能保持原有的网站结构精确不变。只需要把抓取下来的网站放到web服务器(如：Apache)中，就可以实现完整的网站镜像。
</p>

<p><strong>Web-Harvest</strong></br>
<a href="http://web-harvest.sourceforge.net">http://web-harvest.sourceforge.net</a></br>
Web-Harvest 是一个Java开源Web数据抽取工具。它能够收集指定的Web页面并从这些页面中提取有用的数据。Web-Harvest主要是运用了像XSLT,
XQuery,正则表达式等这些技术来实现对text/xml的操作。
</p>

<p><strong>Spiderpy</strong></br>
<a href="http://pyspider.sourceforge.net/">http://pyspider.sourceforge.net/</a></br>
spiderpy是一个基于Python编码的一个开源web爬虫工具，允许用户收集文件和搜索网站，并有一个可配置的界面。
</p>

<p><strong>The Spider Web Network Xoops Mod Team</strong></br>
<a href="http://www.tswn.com/">http://www.tswn.com/</a></br>
pider Web Network Xoops Mod是一个Xoops下的模块，完全由PHP语言实现。
</p>

<p><strong>HiSpider</strong></br>
<a href="https://code.google.com/p/hispider/">https://code.google.com/p/hispider/</a></br>
Hispider is a fast and high performance spider with high speed</br>
严格说只能是一个spider系统的框架, 没有细化需求, 目前只是能提取URL, URL排重, 异步DNS解析, 队列化任务, 支持N机分布式下载, 
支持网站定向下载(需要配置hispiderd.ini whitelist).</br></br>
特征和用法:</br>
基于unix/linux系统的开发</br>
异步DNS解析</br>
URL排重</br>
支持HTTP 压缩编码传输 gzip/deflate</br>
字符集判断自动转换成UTF-8编码</br>
文档压缩存储</br>
支持多下载节点分...
</p>

