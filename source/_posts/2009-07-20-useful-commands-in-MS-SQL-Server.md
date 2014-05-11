---
layout: post
title: "Sql Server数据库常用的命令语句"
date: 2009-07-20 14:44
comments: true
categories: Engineering
tags: SQL
---
<p>1. 查看数据库的版本 </br>
select @@version</p>

<p>2. 查看数据库所在机器操作系统参数 </br>
exec master..xp_msver</p>

<p>3. 查看数据库启动的参数 </br>
sp_configure</p>

<p>4. 查看数据库启动时间 </br>
select convert(varchar(30),login_time,120) from   master..sysprocesses where spid=1</br>
查看数据库服务器名和实例名 </br>
print 'Server Name...............: ' + convert(varchar(30),@@SERVERNAME) </br>
print 'Instance..................: ' + convert(varchar(30),@@SERVICENAME) </p>

<!--more-->

<p>5. 查看所有数据库名称及大小 </br>
sp_helpdb</br>
重命名数据库用的SQL </br>
sp_renamedb 'old_dbname', 'new_dbname'</p>

<p>6. 查看所有数据库用户登录信息 </br>
sp_helplogins</br>
查看所有数据库用户所属的角色信息 </br>
sp_helpsrvrolemember</br>
修复迁移服务器时孤立用户时,可以用的fix_orphan_user脚本或者LoneUser过程</br>
更改某个数据对象的用户属主 </br>
sp_changeobjectowner [@objectname =] 'object', [@newowner =] 'owner'</br>
注意: 更改对象名的任一部分都可能破坏脚本和存储过程。</br>
把一台服务器上的数据库用户登录信息备份出来可以用add_login_to_aserver脚本</p>

<p>7. 查看链接服务器 </br>
sp_helplinkedsrvlogin</br>
查看远端数据库用户登录信息</br> 
sp_helpremotelogin</p>

<p>8.查看某数据库下某个数据对象的大小 </br>
sp_spaceused @objname</br>
还可以用sp_toptables过程看最大的N(默认为50)个表</br>
查看某数据库下某个数据对象的索引信息 </br>
sp_helpindex @objname</br>
还可以用SP_NChelpindex过程查看更详细的索引情况 </br>
SP_NChelpindex @objname</br>
clustered索引是把记录按物理顺序排列的，索引占的空间比较少。 </br>

对键值DML操作十分频繁的表我建议用非clustered索引和约束，fillfactor参数都用默认值。</br>
   查看某数据库下某个数据对象的的约束信息 </br>
   sp_helpconstraint @objname</p>
   
<p>9.查看数据库里所有的存储过程和函数 </br>
use @database_name </br>
sp_stored_procedures </br>
查看存储过程和函数的源代码 </br>
sp_helptext '@procedure_name'</br>
查看包含某个字符串@str的数据对象名称 </br>
select distinct object_name(id) from syscomments where text like '%@str%'</br>
创建加密的存储过程或函数在AS前面加WITH ENCRYPTION参数</br>
解密加密过的存储过程和函数可以用sp_decrypt过程</p>

<p>10.查看数据库里用户和进程的信息 </br>
sp_who </br>
查看SQL Server数据库里的活动用户和进程的信息 </br>
sp_who 'active' </br>
查看SQL Server数据库里的锁的情况 </br>
sp_lock</br>
进程号1--50是SQL Server系统内部用的,进程号大于50的才是用户的连接进程. </br>
    spid是进程编号,dbid是数据库编号,objid是数据对象编号 </br>
   查看进程正在执行的SQL语句 </br>
   dbcc inputbuffer ()</br>
推荐大家用经过改进后的sp_who3过程可以直接看到进程运行的SQL语句 </br>
sp_who3</br>
检查死锁用sp_who_lock过程 </br>
sp_who_lock</p>

<p>11.收缩数据库日志文件的方法 </br>
收缩简单恢复模式数据库日志，收缩后@database_name_log的大小单位为M </br>
backup log @database_name with no_log </br>
dbcc shrinkfile (@database_name_log, 5) </br>
12.分析SQL Server SQL 语句的方法:</br>
set statistics time {on | off} </br>
set statistics io {on | off} </br>
图形方式显示查询执行计划</br>
在查询分析器->查询->显示估计的评估计划(D)-Ctrl-L 或者点击工具栏里的图形</br>
文本方式显示查询执行计划 </br>
set showplan_all {on | off}</br>
set showplan_text { on | off } </br>
set statistics profile { on | off }</p>

<p>13.出现不一致错误时，NT事件查看器里出3624号错误，修复数据库的方法</br>

先注释掉应用程序里引用的出现不一致性错误的表，然后在备份或其它机器上先恢复然后做修复操作</br>
alter database [@error_database_name] set single_user</br>
修复出现不一致错误的表</br>
dbcc checktable('@error_table_name',repair_allow_data_loss)</br>
或者可惜选择修复出现不一致错误的小型数据库名</br>
dbcc checkdb('@error_database_name',repair_allow_data_loss) </br>
alter database [@error_database_name] set multi_user </br>
CHECKDB 有3个参数: </br>
repair_allow_data_loss 包括对行和页进行分配和取消分配以改正分配错误、结构行或页的错误，以及删除已损坏的文本对象，
这些修复可能会导致一些数据丢失。修复操作可以在用户事务下完成以允许用户回滚所做的更改。如果回滚修复，则数据库仍会
含有错误，应该从备份进行恢复。如果由于所提供修复等级的缘故遗漏某个错误的修复，则将遗漏任何取决于该修复的修复。
修复完成后，请备份数据库。 </br>
repair_fast 进行小的、不耗时的修复操作，如修复非聚集索引中的附加键。 这些修复可以很快完成，并且不会有丢失数据的危险。 </br>
repair_rebuild 执行由 repair_fast 完成的所有修复，包括需要较长时间的修复（如重建索引）。 </br>
执行这些修复时不会有丢失数据的危险。</p>

<p>本文来源于Woody的鸟窝(Woody's Blog) http://www.smartgz.com</p>