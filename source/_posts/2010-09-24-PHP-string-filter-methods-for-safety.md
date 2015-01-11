---
layout: post
title: "PHP字符串安全过滤全攻略"
date: 2010-09-24 13:28
comments: true
categories: Program
tags: PHP 安全
---
<p>php安全过滤是防止注入的第一道防线，不得大意。提到PHP的安全过滤，不得不提的两个东西是`set_magic_quotes_runtime` 和 `magic_quotes_gpc`。</p>

<p>`set_magic_quotes_runtime()` 可以让程序员在代码中动态开启或关闭 `magic_quotes_runtime`，`set_magic_quotes_runtime(1)` 表示开启，
`set_magic_quotes_runtime(0)` 则表示关闭。当`set_magic_quotes_runtime(1)`时，从数据库或通过`fread`之类的函数读取的文本，将自动对' "和\自动
加上反斜杠\进行转义，防止溢出。这在对数据库的数据进行转移的时候非常有用。但在一般情况下，应当将其关闭，否则从数据库读取出来的数据单引
号、双引号和反斜杠都会被加上\，导致显示不正常。像Discuz，PHPWind都在公共文件的头部加上一句 `set_magic_quotes_runtime(0);` 强制关闭 
`magic_quotes_runtime` 。</p>

<p>`magic_quotes_gpc` 和 `magic_quotes_runtime` 的区别在于，`magic_quotes_gpc` 是对通过GET、POST、COOKIE传递的数据进行转义，一般在数据入库前
要先进行转义，`magic_quotes_gpc`不能在代码中动态开启或关 闭，需要到`php.ini`将`magic_quotes_gpc`设置为on或off，代码中可以用`get_magic_quotes_gpc`
获取 `magic_quotes_gpc`的状态。当`magic_quotes_gpc`为off时，需要手工对数据进行addslashes，代码如下：</p>
<!--more-->
{% codeblock %}
if (!get_magic_quotes_gpc()) {    
     add_slashes($_GET);
     add_slashes($_POST);
     add_slashes($_COOKIE);
}    
   
function add_slashes($string) {    
     if (is_array($string)) {    
         foreach ($string as $key => $value) {    
             $string[$key] = add_slashes($value);    
         }    
     } else {    
         $string = addslashes($string);    
     }    
     return $string;    
}  
{% endcodeblock %}

<p>php防注入函数,字符过滤函数</p>
{% codeblock lang:php %}
//解码
function htmldecode($str)
{
	if(empty($str)) return;
	if($str=="") return $str;
	$str=str_replace("sel&#101;ct","select",$str);
	$str=str_replace("jo&#105;n","join",$str);
	$str=str_replace("un&#105;on","union",$str);
	$str=str_replace("wh&#101;re","where",$str);
	$str=str_replace("ins&#101;rt","insert",$str);
	$str=str_replace("del&#101;te","delete",$str);
	$str=str_replace("up&#100;ate","update",$str);
	$str=str_replace("lik&#101;","like",$str);
	$str=str_replace("dro&#112;","drop",$str);
	$str=str_replace("cr&#101;ate","create",$str);
	$str=str_replace("mod&#105;fy","modify",$str);
	$str=str_replace("ren&#097;me","rename",$str);
	$str=str_replace("alt&#101;r","alter",$str);
	$str=str_replace("ca&#115;","cast",$str);
	$str=str_replace("&amp;","&",$str);
	$str=str_replace("&gt;",">",$str);
	$str=str_replace("&lt;","<",$str);
	$str=str_replace("&nbsp;",chr(32),$str);
	$str=str_replace("&nbsp;",chr(9),$str);
	//$str=str_replace("&#160;&#160;&#160;&#160;",chr(9),$str);
	$str=str_replace("&",chr(34),$str);
	$str=str_replace("&#39;",chr(39),$str);
	$str=str_replace("<br />",chr(13),$str);
	$str=str_replace("''","'",$str);
	return $str;
}
//编码
function htmlencode($str)
{
	if(empty($str)) return;
	if($str=="") return $str;
	$str=trim($str);
	$str=str_replace("&","&amp;",$str);
	$str=str_replace(">","&gt;",$str);
	$str=str_replace("<","&lt;",$str);
	$str=str_replace(chr(32),"&nbsp;",$str);
	$str=str_replace(chr(9),"&nbsp;",$str);
	//$str=str_replace(chr(9),"&#160;&#160;&#160;&#160;",$str);
	$str=str_replace(chr(34),"&",$str);
	$str=str_replace(chr(39),"&#39;",$str);
	$str=str_replace(chr(13),"<br />",$str);
	$str=str_replace("'","''",$str);
	$str=str_replace("select","sel&#101;ct",$str);
	$str=str_replace("join","jo&#105;n",$str);
	$str=str_replace("union","un&#105;on",$str);
	$str=str_replace("where","wh&#101;re",$str);
	$str=str_replace("insert","ins&#101;rt",$str);
	$str=str_replace("delete","del&#101;te",$str);
	$str=str_replace("update","up&#100;ate",$str);
	$str=str_replace("like","lik&#101;",$str);
	$str=str_replace("drop","dro&#112;",$str);
	$str=str_replace("create","cr&#101;ate",$str);
	$str=str_replace("modify","mod&#105;fy",$str);
	$str=str_replace("rename","ren&#097;me",$str);
	$str=str_replace("alter","alt&#101;r",$str);
	$str=str_replace("cast","ca&#115;",$str);
	return $str;
} 
{% endcodeblock %}