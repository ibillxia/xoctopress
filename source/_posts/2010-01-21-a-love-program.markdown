---
layout: post
title: "一个爱情程序"
date: 2010-01-21 22:13
comments: true
categories: Program
tags: Love
---
<p>一个很有趣的爱情程序</p>
{% codeblock %}
RESULT   love(boy,   girl)     
  {     
  　　if(   boy.有房()   AND   boy.有车()   )     
  　　{     
  　　　boy.Set(Nothing);     
  　　　return   girl.嫁给(boy);     
  　　}     
  　　else   if(   girl.愿意等()   )     
  　　{     
  　　　next_year:     
  　　　for(   day=1;   day<=365;   day++)     
  　　　{     
  　　　　if(   day   ==   情人节   )     
  　　　　　if(   boy.GiveGirl(玫瑰)   )     
  　　　　　　girl.感情++;     
  　　　　　else     
  　　　　　　girl.感情--;     
  　　　　if(   day   ==   girl.生日)     
  　　　　　if(   boy.GiveGirl(玫瑰)   )     
  　　　　　　girl.感情++;     
  　　　　　else     
  　　　　　　girl.感情--;     
  　　　　boy.拼命赚钱();     
  　　　}     
  　　　年龄++;     
  　　　girl.感情--;     
  　　　if(   boy.有房()   AND   boy.有车()   )     
  　　　{     
  　　　　boy.Set(Nothing);     
  　　　　return   girl.嫁给(boy);     
  　　　}     
  　　　else   if(   boy.赚钱   >   100,000   AND   girl.感情   >   8   )     
  　　　　goto   next_year;     
  　　　else     
  　　　　return   girl.goto(   another_boy);     
  　　}     
  　　return   girl.goto(   another_boy);
  }
//有看懂吗，看懂了就很有意思。看不懂就加油！！
{% endcodeblock %}

