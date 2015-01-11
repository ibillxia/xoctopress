---
layout: post
title: "PHP格式化打印数组，调试有用"
date: 2010-08-25 10:08
comments: true
categories: Program
tags: PHP FleaPHP 调试
---
<p>以下是从FleaPHP上挖来的，感谢FleaPHP的开发者们。</p>
{% codeblock lang:php %}
/**
* 输出变量的内容，通常用于调试
*
* @package Core
*
* @param mixed $vars 要输出的变量
* @param string $label
* @param boolean $return
*/
function dump($vars, $label = '', $return = false)
{
    if (ini_get('html_errors')) {
        $content = "<pre>\n";
        if ($label != '') {
            $content .= "<strong>{$label} :</strong>\n";
        }
        $content .= htmlspecialchars(print_r($vars, true));
        $content .= "\n</pre>\n";
    } else {
        $content = $label . " :\n" . print_r($vars, true);
    }
    if ($return) { return $content; }
    echo $content;
    return null;
}
{% endcodeblock %}
<!--more-->
<p>所以只要在自己的代码脚本所有函数外面，ctrl+c/ctrl+v上面这段代码，就可以有dump()函数格式化打印数组了。</p>