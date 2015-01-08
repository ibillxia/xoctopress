---
layout: post
title: "给Octpress博客添加返回顶部按钮"
date: 2013-06-30 10:47
comments: true
categories: Program
tags: Octopress CSS jQuery
---
有时候，博客文章太长，需要返回顶部时，需要用鼠标拖着滚动条向上好半天，这里提供一个用 jQuery 来实现的动态上滚的示例。这个示例完全参考和翻译自 webdesignerwall 的 blog：[http://webdesignerwall.com/tutorials/animated-scroll-to-top](http://webdesignerwall.com/tutorials/animated-scroll-to-top)，其中有部分删改，并在本人的 blog 上实现。

主要包含HTML和CSS的设计，基于jQuery的JS的设计。另外还有一点小trick

## Design & CSS
相关的 HTML 代码很简单，在source/_include/custom/footer.html中添加如下代码：

``` html
<p id = "back-top">
	<a href="#top"><span></span>Back to Top</a>
</p>
```

<!--more-->

对应的 CSS 样式的设置如下：（这段代码同样的放在source/_include/custom/footer.html文件中）

``` css
<style type="text/css">
#back-top {
	position: fixed;
	bottom: 50px;
	right: 100px;
}

#back-top a {
	width: 80px;
	display: block;
	text-align: center;
	font: 11px/100% Arial, Helvetica, sans-serif;
	text-transform: uppercase;
	text-decoration: none;
	color: #bbb;

	/* transition */
	-webkit-transition: 1s;
	-moz-transition: 1s;
	transition: 1s;
}
#back-top a:hover {
	color: #000;
}

/* arrow icon (span tag) */
#back-top span {
	width: 80px;
	height: 80px;
	display: block;
	margin-bottom: 7px;
	background: #ddd url(../../images/up-arrow.png) no-repeat center center;

	/* rounded corners */
	-webkit-border-radius: 15px;
	-moz-border-radius: 15px;
	border-radius: 15px;

	/* transition */
	-webkit-transition: 1s;
	-moz-transition: 1s;
	transition: 1s;
}
/*
#back-top a:hover span {
	background-color: #888;
}
*/
</style>
```

上面的 css 中用到了一张图片up-arrow.png，放在source/images/目录下，图片如下：
<center>{% img /images/up-arrow.png %}</center>
这是从google image里面随便找的一个，你也可以找一个自己喜欢的图片。

## jQuery部分
HTML 和 CSS 样式设置好了之后，最后就是添加 JavaScript 事件响应代码了，这里是基于 jQuery 实现的。代码如下：（这段代码还是放在source/_include/custom/footer.html文件中）

``` js
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js"></script>
<script type="text/javascript">
$(document).ready(function(){
	// hide #back-top first
	$("#back-top").hide();
	
	// fade in #back-top
	$(function () {
		$(window).scroll(function () {
			if ($(this).scrollTop() > 100) {
				$('#back-top').fadeIn();
			} else {
				$('#back-top').fadeOut();
			}
		});

		// scroll body to 0px on click
		$('#back-top a').click(function () {
			$('body,html').animate({
				scrollTop: 0
			}, 800);
			return false;
		});
	});

});
</script>
```

## 一个Trick
在上面的HTML代码中，我们将一个链接添加到了ID为 \#top 的里面，这个 \#top 标签是 &lt;body&gt; 标签的ID，这样即使浏览器不支持相关的JS，通过这个link也实现了返回顶部的功能。
