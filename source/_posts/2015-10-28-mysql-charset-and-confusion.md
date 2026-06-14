---   
layout: post   
title: "MySQL乱码问题详解与解决方案"   
date: 2015-10-28 17:12   
comments: true   
categories: Program   
tags: MySQL 数据库 字符集 编码   
---   
   
本文节选自[10分钟学会理解和解决MySQL乱码问题](http://cenalulu.github.io/mysql/mysql-mojibake/)     
PS: 原文博主通过MySQL垂直深耕，成功进入Facebook了，祝福。   
   
## 1. MySQL乱码的成因      
<center>{% img /images/2015/IMAG2015102801.png %}</center>   
<p>要了解为什么会出现乱码，需要理解从客户端发起请求到MySQL存储数据，再到取回客户端的过程中，哪些环节会有编码/解码的行为。</p>   
   
<!--more-->   
   
### 1.1 存入MySQL经历的编码转换      
<center>{% img /images/2015/IMAG2015102802.png %}</center>   
<p>存入过程有3次编码/解码：</p>   
<p>1. Terminal根据字符编码转换成二进制流<br/>   
2. Server通过character-set-client解码<br/>   
3. 判断character-set-client和目标表的charset是否一致，不一致则转换</p>   
   
### 1.2 从MySQL取出数据经历的编码转换      
<center>{% img /images/2015/IMAG2015102803.png %}</center>   
<p>取出过程同样有3次编码/解码：</p>   
<p>1. 用表字符集编码进行解码<br/>   
2. 将数据转换为character-set-client的编码<br/>   
3. Server通过网络传输到远端client</p>   
   
### 1.3出现乱码的原因    
MySQL数据存入和读取过程有3次编码/解码的过程：客户端编码，MySQL Server解码，Client编码向表编码的转换     
三步中，只要两步或者两部以上的编码有不一致就有可能出现编解码错误。     
1. 存入和取出时对应环节的编码不一致      
2. 单个流程中三步的编码不一致     
   
   
## 2.如何避免乱码   
理解了上面的内容，要避免乱码就显得很容易了。     
只要做到“三位一体”，即 客户端，MySQL character-set-client，table charset三个字符集完全一致就可以保证一定不会有乱码出现了。   
   
最简单的方式是将客户端、连接、服务端统一设置为UTF-8（适合于还未写入数据造成乱码的情况，已经有乱码的修复见下文）：      
   
```   
SET NAMES 'utf8mb4';     
-- 等同于以下三条语句：     
SET character_set_client = utf8mb4;     
SET character_set_results = utf8mb4;     
SET character_set_connection = utf8mb4;     
```   
   
## 3.如何修复已经编码损坏的数据     
原文有列举一些错误的方法，这里就略过了，直接说正确的方法      
   
### 方法一 Dump & Reload     
这个方法比较笨，但也比较好操作和理解。简单的说分为以下三步：     
   
- 通过错进错出的方法，导出到文件     
- 用正确的字符集修改新表     
- 将之前导出的文件导回到新表中     
   
举例，我们用UTF-8将数据“错进”到latin1编码的表中。现在需要将表编码修改为UTF-8可以使用以下命令     

```   
shell> mysqldump -u root -p -t --skip-set-charset --default-character-set=utf8 test charset_test_latin1 > data.sql   
#确保导出的文件用文本编辑器在UTF-8编码下查看没有乱码   
shell> mysql -uroot -p -e 'create table charset_test_latin1 (id int primary key auto_increment, char_col varchar(50)) charset = utf8' test   
shell> mysql -uroot -p  --default-character-set=utf8 test < data.sql   
```   
   
### 方法二 Convert to Binary & Convert Back     
这种方法比较取巧，用的是将二进制数据作为中间数据的做法来实现的。由于，MySQL再将有编码意义的数据流，转换为无编码意义的二进制数据的时候并不做实际的数据转换。而从二进制数据准换为带编码的数据时，又会用目标编码做一次编码转换校验。通过这两个特性就相当于在MySQL内部模拟了一次“错出”，将乱码“拨乱反正”了。   
   
还是用上面那个例子举例，我们用UTF-8将数据“错进”到latin1编码的表中。现在需要将表编码修改为UTF-8可以使用以下命令   

```   
mysql> ALTER TABLE charset_test_latin1 MODIFY COLUMN char_col VARBINARY(50);   
mysql> ALTER TABLE charset_test_latin1 MODIFY COLUMN char_col varchar(50) character set utf8;   
```   
   
## 参考资料      
[1][10分钟学会理解和解决MySQL乱码问题](https://cenalulu.github.io/mysql/mysql-mojibake/)  
[2][MySQL Character Sets文档](https://dev.mysql.com/doc/refman/8.0/en/charset.html)  
