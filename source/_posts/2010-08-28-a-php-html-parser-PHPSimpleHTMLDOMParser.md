---
layout: post
title: "超好的HTML解析工具PHP Simple HTML DOM Parser"
date: 2010-08-28 20:49
comments: true
categories: Program
tags: PHP HTML DOM
---
<p>采用PHP5+ 开发的一个简单的 PHP HTML DOM 分析，支持 invalid HTML 并提供非常简单的方式来操作 HTML 元素。在 HMTL 页面
上查找标签所使用的语法与 jQuery （一个轻量级，实用的 javascript 框架） 相似，从页面中抽取内容只需要一行代码。开源代码：
<a href="http://sourceforge.net/projects/simplehtmldom/">http://sourceforge.net/projects/simplehtmldom/</a> </p>

<p>它具有以下几个特点：</br>
1. 只支援 PHP5 以上. </br>
2. 可以分析不严谨 (invalid) 的 HTML. </br>
3. 支援简单的 CSS Selector. </br>
4. 简单的 DOM 操作. </br>
5. 会维持 HTML 中的原始格式 .</br>
下面是使用手册上举的几个简单的使用示例。</p>
<!--more-->
<p>如何读取 HTML 元素 </p>
{% codeblock %}
<? 
include('html_dom_parser.php');
$dom = file_get_dom('http://www.google.com/');
// 找出所有网页连结 
$result = $dom->find('a'); 
foreach($result as $v) {echo $v->href . '<br>';}
// 找出所有网页图片 
$result = $dom->find('img'); 
foreach($result as $v) {echo $v->src . '<br>';}
// 找出所有网页中所有 id=gbar 的 div 标签 
$result = $dom->find('div#gbar'); 
foreach($result as $v) {echo $v->innertext . '<br>';}
// 找出所有网页中所有 calss=gb1 的 span 标签 
$result = $dom->find('span.gb1'); 
foreach($result as $v) {echo $v->outertext . '<br>';}
// 找出所有网页中所有 align=center 的 'td 标签 
$result = $dom->find('td[align=center]'); 
foreach($result as $v) {echo $v->outertext . '<br>';} 
?>
{% endcodeblock %}

<p>如何修改 HTML 元素 </p>
{% codeblock lang:php %}
<? 
include('html_dom_parser.php');
$dom = file_get_dom('http://www.google.com/');
// 移除网页中所有图片 
$ret = $dom->find('img'); 
foreach($ret as $v) {$v->outertext = '';}
// 修改网页中所有 input 标签 
$ret = $dom->find('input'); 
foreach($ret as $v) {$v->outertext = '[INPUT]';}
// 显示修改后的网页 
echo $dom->save(); 
?>
{% endcodeblock %}

<p>Slashdot网站内容抓取</p>
{% codeblock lang:php %}
// Create DOM from URL
$html = file_get_html('http://slashdot.org/');
// Find all article blocks
foreach($html->find('div.article') as $article) {
    $item['title']     = $article->find('div.title', 0)->plaintext;
    $item['intro']    = $article->find('div.intro', 0)->plaintext;
    $item['details'] = $article->find('div.details', 0)->plaintext;
    $articles[] = $item;
}
print_r($articles);
{% endcodeblock %}
