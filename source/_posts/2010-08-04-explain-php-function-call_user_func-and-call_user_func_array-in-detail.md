---
layout: post
title: "PHP函数call_user_func和call_user_func_array详解"
date: 2010-08-04 21:38
comments: true
categories: Program
tags: PHP 库函数
---
<p>call\_user_func函数类似于一种特别的调用函数的方法，使用方法如下：</p>

``` php
function a($b,$c) 
{
	echo $b;
	echo $c;
}
call_user_func('a', "111","222");
call_user_func('a', "333","444");
//显示 111 222 333 444
```

<!--more-->
<p>调用类内部的方法比较奇怪，居然用的是array，不知道开发者是如何考虑的，当然省去了new，也是满有新意的:</p>

``` php
class a {
	function b($c) 
	{
		echo $c;
	}
}
call_user_func(array("a", "b"),"111");
//显示 111
```

<p>call_user_func_array函数和call_user_func很相似，只不过是换了一种方式传递了参数，让参数的结构更清晰:</p>

``` php
unction a($b, $c) 
{
	echo $b;
	echo $c;
}
call_user_func_array('a', array("111", "222"));
//显示 111 222
```

<p>call_user_func_array函数也可以调用类内部的方法的</p>

``` php
Class ClassA {
	function bc($b, $c) {
		$bc = $b + $c;
		echo $bc;
	}
}
call_user_func_array(array('ClassA','bc'), array("111", "222"));
//显示 333
```

<p>call_user_func函数和call_user_func_array函数都支持引用，这让他们和普通的函数调用更趋于功能一致:</p>

``` php
function a(&$b)
{
	$b++;
}
$c = 0;
call_user_func('a', &$c);
echo $c;//显示 1
call_user_func_array('a', array(&$c));
echo $c;//显示 2
```

<p>一个可以用于调试输出的例子：</p>

``` php
function debug($var, $val) 
{
    echo "***DEBUGGING\nVARIABLE: $var\nVALUE:";
    if (is_array($val) || is_object($val) || is_resource($val)) {
        print_r($val);
    } else {
        echo "\n$val\n";
    }
    echo "***\n";
}

$c = mysql_connect();
$host = $_SERVER["SERVER_NAME"];

call_user_func_array('debug', array("host", $host));
call_user_func_array('debug', array("c", $c));
call_user_func_array('debug', array("_POST", $_POST));
```

<p>另外，如果和伪重载结合，还可以这样用：</p>

``` php
function otest1 ($a)
{
    echo( '一个参数' );
}

function otest2 ( $a, $b)
{
    echo( '二个参数' );
}

function otest3 ( $a ,$b,$c)
{
    echo( '三个啦' );
}

function otest ()
{
    $args = func_get_args();
    $num = func_num_args();
    call_user_func_array( 'otest'.$num, $args );
}

otest(1,2);  //调用第一个函数，输出：一个参数
```
