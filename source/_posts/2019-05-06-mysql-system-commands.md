---
layout: post
title: "MySQL常用系统命令"
date: 2019-05-06 22:30
comments: true
categories: Program
tags: MySQL
---

# 1 show processlist

SHOW PROCESSLIST显示哪些线程正在运行。您也可以使用mysqladmin processlist语句得到此信息。如果您有SUPER权限，您可以看到所有线程。否则，您只能看到您自己的线程（也就是，与您正在使用的MySQL账户相关的线程）。如果有线程在update或者insert 某个表，此时进程的status为updating 或者 sending data。

如果您得到“too many connections”错误信息，并且想要了解正在发生的情况，本语句是非常有用的。MySQL保留一个额外的连接，让拥有SUPER权限的账户使用，以确保管理员能够随时连接和检查系统（假设您没有把此权限给予所有的用户）。

<!-- more -->

|Status|含义| 
|-|-| 
|Checking table|正在检查数据表（这是自动的）。| 
|Closing tables|正在将表中修改的数据刷新到磁盘中，同时正在关闭已经用完的表。这是一个很快的操作，如果不是这样的话，就应该确认磁盘空间是否已经满了或者磁盘是否正处于重负中。| 
|Connect Out|复制从服务器正在连接主服务器。|
|Copying to tmp table on disk|由于临时结果集大于tmp_table_size，正在将临时表从内存存储转为磁盘存储以此节省内存。|
|Creating tmp table|正在创建临时表以存放部分查询结果。|
|deleting from main table|服务器正在执行多表删除中的第一部分，刚删除第一个表。|
|deleting from reference tables|服务器正在执行多表删除中的第二部分，正在删除其他表的记录。|
|Flushing tables|正在执行FLUSH TABLES，等待其他线程关闭数据表。|
|Killed|发送了一个kill请求给某线程，那么这个线程将会检查kill标志位，同时会放弃下一个kill请求。MySQL会在每次的主循环中检查kill标志位，不过有些情况下该线程可能会过一小段才能死掉。如果该线程程被其他线程锁住了，那么kill请求会在锁释放时马上生效。|
|Locked|被其他查询锁住了。|
|Sending data|正在处理SELECT查询的记录，同时正在把结果发送给客户端。|
|Sorting for group|正在为GROUP BY做排序。|
|Sorting for order|正在为ORDER BY做排序。|
|Opening tables|这个过程应该会很快，除非受到其他因素的干扰。例如，在执ALTER TABLE或LOCK TABLE语句行完以前，数据表无法被其他线程打开。正尝试打开一个表。|
|Removing duplicates|正在执行一个SELECT DISTINCT方式的查询，但是MySQL无法在前一个阶段优化掉那些重复的记录。因此，MySQL需要再次去掉重复的记录，然后再把结果发送给客户端。|
|Reopen table|获得了对一个表的锁，但是必须在表结构修改之后才能获得这个锁。已经释放锁，关闭数据表，正尝试重新打开数据表。|
|Repair by sorting|修复指令正在排序以创建索引。|
|Repair with keycache|修复指令正在利用索引缓存一个一个地创建新索引。它会比Repair by sorting慢些。|
|Searching rows for update|正在讲符合条件的记录找出来以备更新。它必须在UPDATE要修改相关的记录之前就完成了。|
|Sleeping|正在等待客户端发送新请求。|
|System lock|正在等待取得一个外部的系统锁。如果当前没有运行多个mysqld服务器同时请求同一个表，那么可以通过增加--skip-external-locking参数来禁止外部系统锁。|
|Upgrading lock|INSERT DELAYED正在尝试取得一个锁表以插入新记录。|
|Updating|正在搜索匹配的记录，并且修改它们。|
|User Lock|正在等待GET_LOCK()。|
|Waiting for tables|该线程得到通知，数据表结构已经被修改了，需要重新打开数据表以取得新的结构。然后，为了能的重新打开数据表，必须等到所有其他线程关闭这个表。以下几种情况下会产生这个通知：FLUSH TABLES tbl_name, ALTER TABLE, RENAME TABLE, REPAIR TABLE, ANALYZE TABLE,或OPTIMIZE TABLE。|
|waiting for handler insert|INSERT DELAYED已经处理完了所有待处理的插入操作，正在等待新的请求。|

<br>
大部分状态对应很快的操作，只要有一个线程保持同一个状态好几秒钟，那么可能是有问题发生了，需要检查一下。还有其他的状态没在上面中列出来，不过它们大部分只是在查看服务器是否有存在错误是才用得着。

# 2 show full processlist

`show processlist;`只列出前100条，如果想全列出请使用`show full processlist;`

# 3 show open tables

这条命令能够查看当前有那些表是打开的。In_use列表示有多少线程正在使用某张表，Name_locked表示表名是否被锁，这一般发生在Drop或Rename命令操作这张表时。所以这条命令不能帮助解答我们常见的问题：当前某张表是否有死锁，谁拥有表上的这个锁等。
`show open tables from database;`

# 4 show status like ‘%lock%’

查看服务器状态。

# 5 show engine innodb status\G

MySQL 5.1之前的命令是：`show innodbstatus\G;`，MySQL 5.5使用上面命令即可查看innodb引擎的运行时信息。

# 6 show variables like ‘%timeout%’

查看服务器配置参数。


## 参考资料
[mysql5.0经常出现 err=1205 - Lockwait timeout exceeded; try restarting transaction](http://www.imysql.cn/node/165)   
[mysql show processlist命令详解](http://www.cnblogs.com/JulyZhang/archive/2011/01/28/1947165.html)   
[MySQL锁](http://blog.csdn.net/c__ilikeyouma/article/details/8541195)   
[SHOW INNODB STATUS提示语法错误？](http://www.itpub.net/thread-1454597-1-1.html)   
[SHOW OPEN TABLES – what is in your tablecache](http://blog.sina.com.cn/s/blog_4d1f40c00100rsse.html)  
