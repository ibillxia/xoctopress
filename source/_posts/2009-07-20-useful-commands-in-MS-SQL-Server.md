---
layout: post
title: "Sql Server数据库常用的命令语句"
date: 2009-07-20 14:44
comments: true
categories: Engineering
tags: SQL 数据库
---
**1. 查看数据库的版本**   
```
select @@version
```

**2. 查看数据库所在机器操作系统参数** 
```
exec master..xp_msver
```

**3. 查看数据库启动的参数**  
```
sp_configure
```

**4. 查看数据库启动时间**  
```
select convert(varchar(30),login_time,120) from   master..sysprocesses where spid=1
```
查看数据库服务器名和实例名

```
print 'Server Name...............: ' + convert(varchar(30),@@SERVERNAME) 
print 'Instance..................: ' + convert(varchar(30),@@SERVICENAME)
```

<!--more-->

**5. 查看所有数据库名称及大小**  
```
sp_helpdb
```  
重命名数据库用的SQL  
```
sp_renamedb 'old_dbname', 'new_dbname'
```

**6. 查看所有数据库用户登录信息**  
```
sp_helplogins
```  
查看所有数据库用户所属的角色信息
```
sp_helpsrvrolemember
```  
修复迁移服务器时孤立用户时,可以用的 `fix_orphan_user` 脚本或者 `LoneUser` 过程  
更改某个数据对象的用户属主  
```
sp_changeobjectowner [@objectname =] 'object', [@newowner =] 'owner'
```
注意: 更改对象名的任一部分都可能破坏脚本和存储过程。
把一台服务器上的数据库用户登录信息备份出来可以用 `add_login_to_aserver` 脚本</p>

**7. 查看链接服务器**  
```
sp_helplinkedsrvlogin
```
查看远端数据库用户登录信息  
```
sp_helpremotelogin
```

**8.查看某数据库下某个数据对象的大小**  
```
sp_spaceused @objname
```
还可以用 `sp_toptables` 过程看最大的N(默认为50)个表  
查看某数据库下某个数据对象的索引信息  
```
sp_helpindex @objname
```
还可以用 `SP_NChelpindex` 过程查看更详细的索引情况  
```
SP_NChelpindex @objname
```
`clustered` 索引是把记录按物理顺序排列的，索引占的空间比较少。 

对键值DML操作十分频繁的表我建议用非 `clustered` 索引和约束，`fillfactor` 参数都用默认值。  
查看某数据库下某个数据对象的的约束信息  
```
sp_helpconstraint @objname
```

**9.查看数据库里所有的存储过程和函数**  
```
use @database_name
sp_stored_procedures
```
查看存储过程和函数的源代码  
```
sp_helptext '@procedure_name'
```
查看包含某个字符串@str的数据对象名称  
```
select distinct object_name(id) from syscomments where text like '%@str%'
```
创建加密的存储过程或函数在AS前面加WITH ENCRYPTION参数  
解密加密过的存储过程和函数可以用 `sp_decrypt` 过程   

**10.查看数据库里用户和进程的信息**  
```
sp_who
```
查看SQL Server数据库里的活动用户和进程的信息  
```
sp_who 'active' 
```
查看SQL Server数据库里的锁的情况  
```
sp_lock
```
进程号1--50是SQL Server系统内部用的,进程号大于50的才是用户的连接进程.  
spid是进程编号,dbid是数据库编号,objid是数据对象编号  
查看进程正在执行的SQL语句  
```
dbcc inputbuffer ()  
```
推荐大家用经过改进后的 `sp_who3` 过程可以直接看到进程运行的SQL语句  
```
sp_who3  
```
检查死锁用 `sp_who_lock` 过程  
```
sp_who_lock
```

**11.收缩数据库日志文件的方法**  
收缩简单恢复模式数据库日志，收缩后 `@database_name_log` 的大小单位为M  
```
backup log @database_name with no_log
dbcc shrinkfile (@database_name_log, 5)
```

**12.分析SQL Server SQL 语句的方法**   
```
set statistics time {on | off}
set statistics io {on | off}
```
图形方式显示查询执行计划  
在查询分析器->查询->显示估计的评估计划(D)-Ctrl-L 或者点击工具栏里的图形   
文本方式显示查询执行计划  
```
set showplan_all {on | off}
set showplan_text { on | off }
set statistics profile { on | off }
```

**13.出现不一致错误时，NT事件查看器里出3624号错误，修复数据库的方法**
先注释掉应用程序里引用的出现不一致性错误的表，然后在备份或其它机器上先恢复然后做修复操作  
```
alter database [@error_database_name] set single_user
```
修复出现不一致错误的表
```
dbcc checktable('@error_table_name',repair_allow_data_loss)
```
或者可惜选择修复出现不一致错误的小型数据库名  
```
dbcc checkdb('@error_database_name',repair_allow_data_loss)
alter database [@error_database_name] set multi_user
```
CHECKDB 有3个参数:   
`repair_allow_data_loss` 包括对行和页进行分配和取消分配以改正分配错误、结构行或页的错误，以及删除已损坏的文本对象，这些修复可能会导致一些数据丢失。修复操作可以在用户事务下完成以允许用户回滚所做的更改。如果回滚修复，则数据库仍会含有错误，应该从备份进行恢复。如果由于所提供修复等级的缘故遗漏某个错误的修复，则将遗漏任何取决于该修复的修复。修复完成后，请备份数据库。  
`repair_fast` 进行小的、不耗时的修复操作，如修复非聚集索引中的附加键。 这些修复可以很快完成，并且不会有丢失数据的危险。  
`repair_rebuild` 执行由 `repair_fast` 完成的所有修复，包括需要较长时间的修复（如重建索引）。  
执行这些修复时不会有丢失数据的危险。</p>
