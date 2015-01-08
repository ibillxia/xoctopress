---
layout: post
title: "Sql Server数据库常用的查询语句"
date: 2009-07-23 22:31
comments: true
categories: Engineering
tags: SQL 数据库
---
## 一、表操作  
例 1 对于表的教学管理数据库中的表 STUDENTS ，可以定义如下： 
```
Create TABLE STUDENTS (SNO NUMERIC (6, 0) NOT NULL 
SNAME CHAR (8) NOT NULL 
AGE NUMERIC(3,0) 
SEX CHAR(2) 
BPLACE CHAR(20) 
PRIMARY KEY(SNO)) 
```

例 2 对于表的教学管理数据库中的表 ENROLLS ，可以定义如下： 
```
Create TABLE ENROLLS(SNO NUMERIC(6,0) NOT NULL 
CNO CHAR(4) NOT NULL 
GRADE INT 
PRIMARY KEY(SNO,CNO) 
FOREIGN KEY(SNO) REFERENCES STUDENTS(SNO) 
FOREIGN KEY(CNO) REFERENCES COURSES(CNO) 
CHECK ((GRADE IS NULL) or (GRADE BETWEEN 0 AND 100))) 
```
<!--more-->
例 3 根据表的 STUDENTS 表，建立一个只包含学号、姓名、年龄的女学生表。 
```
Create TABLE GIRL AS Select SNO, SNAME, AGE 
FROM STUDENTS Where SEX=' 女 '; 
```

例 4 删除教师表 TEACHER 。 
```
Drop TABLE TEACHER 
```

例 5 在教师表中增加住址列。 
```
Alter TABLE TEACHERS ADD (ADDR CHAR(50)) 
```

例 6 把 STUDENTS 表中的 BPLACE 列删除，并且把引用 BPLACE 列的所有视图和约束也一起删除。 
```
Alter TABLE STUDENTS Drop BPLACE CASCADE 
```

例 7 补充定义 ENROLLS 表的主关键字。 
```
Alter TABLE ENROLLS ADD PRIMARY KEY (SNO,CNO) ; 
```

## 二、视图操作（虚表）  
例 9 建立一个只包括教师号、姓名和年龄的视图 FACULTY 。 ( 在视图定义中不能包含 orDER BY 子句 ) 
```
Create VIEW FACULTY AS Select TNO, TNAME, AGE FROM TEACHERS 
```

例 10 从学生表、课程表和选课表中产生一个视图 `GRADE_TABLE` ， 它包括学生姓名、课程名和成绩。 
```
Create VIEW GRADE_TABLE AS Select SNAME,CNAME,GRADE 
FROM STUDENTS,COURSES,ENROLLS 
Where STUDENTS.SNO ＝ ENROLLS.SNO AND 
COURSES.CNO=ENROLLS.CNO 
```

例 11 删除视图 `GRADE_TABLE` 
```
Drop VIEW GRADE_TABLE RESTRICT 
```

## 三、索引操作  
例 12 在学生表中按学号建立索引。 
```
Create UNIQUE INDEX ST ON STUDENTS (SNO,ASC) 
```

例 13 删除按学号所建立的索引。 
```
Drop INDEX ST 
```

## 四、数据库模式操作  
例 14 创建一个简易教学数据库的数据库模式 `TEACHING_DB` ，属主为 `ZHANG` 。 
```
Create SCHEMA TEACHING_DB AUTHRIZATION ZHANG 
```

例 15 删除简易教学数据库模式 `TEACHING_DB` 。  
(1)选用 CASCADE ，即当删除数据库模式时，则本数据库模式和其下属的基本表、视图、索引等全部被删除。  
(2 )选用 RESTRICT ，即本数据库模式下属的基本表、视图、索引等事先已清除，才能删除本数据库模式，否则拒绝删除。 
```
Drop SCHEMA TEACHING_DB CASCADE 
```

## 五、单表操作  
例 16 找出 3 个学分的课程号和课程名。 
```
Select CNO, CNAME  FROM  COURSES  Where  CREDIT= 3 
```
 
例 17 查询年龄大于 22 岁的学生情况。
```
Select * FROM STUDENTS Where AGE ＞ 22 
```

例 18 找出籍贯为河北的男生的姓名和年龄。 
```
Select  SNAME, AGE  FROM  STUDENTS 
Where  BPLACE ＝ ' 河北 ' AND SEX ＝ ' 男 ' 
```

例 19 找出年龄在 20 ～ 23 岁之间的学生的学号、姓名和年龄，并按年龄升序排序。 (ASC （升序）或 DESC （降序）声明排序的方式，缺省为升序。 ) 
```
Select SNO, SNAME, AGE  FROM  STUDENTS 
Where  AGE  BETWEEN  20  AND  23 
orDER BY AGE 
```

例 20 找出年龄小于 23 岁、籍贯是湖南或湖北的学生的姓名和性别。（条件比较运算符＝、＜ 和逻辑运算符 AND （与），此外还可以使用的
运算符有：＞（大于）、＞＝（大于等于）、＜＝（小于等于）、＜＞（不等于）、 NOT （非）、 or （或）等。   
谓词 LIKE 只能与字符串联用，常常是 ` ＜列名＞ LIKE pattern` 的格式。特殊字符 `“_” `和 `“%”` 作为通配符。   
谓词 IN 表示指定的属性应与后面的集合（括号中的值集或某个查询子句的结果）中的某个值相匹配，实际上是一系列的 or （或）的缩写。  
谓词 NOT IN 表示指定的属性不与后面的集合中的某个值相匹配。 </br>
谓词 BETWEEN 是 “ 包含于 … 之中 ” 的意思。） 
```
Select SNAME, SEX FROM STUDENTS 
Where AGE ＜ 23 AND BPLACE LIKE' 湖％ ' 
```
或 
```
Select SNAME, SEX FROM STUDENTS 
Where AGE ＜ 23 AND BPLACE IN （ ' 湖南 ' ， ' 湖北 ' ） 
``` 

 例 21 找出学生表中籍贯是空值的学生的姓名和性别。（在 SQL 中不能使用条件：＜列名＞＝ NULL 。在 SQL 中只有一个特殊的查询条件允许查询 NULL 值：） 
``` 
Select SNAME, SEX FROM STUDENTS Where BPLACE IS NULL 
``` 

## 六、多表操作  
例 22 找出成绩为 95 分的学生的姓名。（子查询） 
```
Select SNAME FROM STUDENTS 
Where 　 SNO ＝ 
(Select SNO FROM ENROLLS Where GRADE ＝ 95) 
```

例 23 找出成绩在 90 分以上的学生的姓名。 
```
Select SNAME FROM STUDENTS 
Where SNO IN 
(Select SNO FROM ENROLLS Where GRADE ＞ 90) 
```
或
``` 
Select SNAME FROM STUDENTS 
Where SNO ＝ ANY 
(Select SNO FROM ENROLLS Where GRADE ＞ 90) 
```

例 24 查询全部学生的学生名和所学课程号及成绩。（连接查询） 
```
Select SNAME, CNO, GRADE FROM STUDENTS, ENROLLS 
Where STUDENTS.SNO ＝ ENROLLS.SNO 
```

例 25 找出籍贯为山西或河北，成绩为 90 分以上的学生的姓名、籍贯和成绩。  
【当构造多表连接查询命令时，必须遵循两条规则。  
第一，连接条件数正好比表数少 1 （若有三个表，就有两个连接条件 ) ；  
第二，若一个表中的主关键字是由多个列组成，则对此主关键字中的每一个列都要有一个连接条件（也有少数例外情况）.】 
```
Select SNAME, BPLACE, GRADE FROM STUDENTS, ENROLLS 
Where BPLACE IN (‘ 山西 ' ， ‘ 河北 ') AND GRADE ＞＝ 90 AND 　 STUDENTS.SNO=ENROLLS.SNO 
```

例 26 查出课程成绩在 80 分以上的女学生的姓名、课程名和成绩。（ FROM 子句中的子查询） 
```
Select SNAME,CNAME, GRADE FROM (Select SNAME, CNAME , GRADE 
FROM STUDENTS, ENROLLS,COURSES Where SEX ＝'女') 
AS TEMP (SNAME, CNAME,GRADE) Where GRADE ＞ 80 
```

#### 表达式与函数的使用  
例 27 查询各课程的学时数。（算术表达式由算术运算符＋、－、 * 、／与列名或数值常量所组成。） 
```
Select CNAME,COURSE_TIME ＝ CREDIT*16 FROM COURSES 
```

例 28 找出教师的最小年龄。【内部函数： SQL 标准中只使用 COUNT 、 SUM 、 AVG 、 MAX 、 MIN 函数，
称之为聚集函数（ Set Function ）。 COUNT 函数的结果是该列统计值的总数目， SUM 函数求该列统计值之和， 
AVG 函数求该列统计值之平均值， MAX 函数求该列最大值， MIN 函数求该列最小值。】 
```
Select MIN(AGE) FROM TEACHERS 
```

<p>例 29 统计年龄小于等于 22 岁的学生人数。（统计） 
``` 
Select COUNT(*) FROM STUDENTS Where AGE < ＝ 22 
```

例 30 找出学生的平均成绩和所学课程门数。 
```
Select SNO, AVG(GRADE), COURSES ＝ COUNT(*) FROM ENROLLS GROUP BY SNO 
```

例 31 找出年龄超过平均年龄的学生姓名。 
```
Select SNAME FROM STUDENTS 
Where AGE ＞ (Select AVG(AGE) FROM STUDENTS) 
```

例 32 找出各课程的平均成绩，按课程号分组，且只选择学生超过 3 人的课程的成绩。【 GROUP BY 与 HAVING  GROUP BY 子句
把一个表按某一指定列（或一些列）上的值相等的原则分组，然后再对每组数据进行规定的操作。 GROUP BY 子句总是跟在 Where 子句
后面，当 Where 子句缺省时，它跟在 FROM 子句后面。 HAVING 子句常用于在计算出聚集之后对行的查询进行控制。】 
```
Select CNO, AVG(GRADE), STUDENTS ＝ COUNT(*) FROM ENROLLS  GROUP BY CNO HAVING COUNT(*) >= 3 
```

## 七、相关子查询   
例 33 查询没有选任何课程的学生的学号和姓名。【当一个子查询涉及到一个来自外部查询的列时，称为相关子查询（ Correlated Subquery) 。
相关子查询要用到存在测试谓词 EXISTS 和 NOT EXISTS ，以及 ALL 、 ANY （ SOME ）等 。】
```
Select SNO, SNAME FROM STUDENTS Where NOT EXISTS 
(Select * FROM ENROLLS Where ENROLLS.SNO=STUDENTS.SNO) 
```

例 34 查询哪些课程只有男生选读。 
```
Select DISTINCT CNAME FROM COURSES C 
Where ' 男 ' ＝ ALL 
(Select SEX FROM ENROLLS , STUDENTS Where ENROLLS.SNO=STUDENTS.SNO AND ENROLLS.CNO=C.CNO) 
```

例 35 要求给出一张学生、籍贯列表，该表中的学生的籍贯省份，也是其他一些学生的籍贯省份。 
```
Select SNAME, BPLACE FROM STUDENTS A Where EXISTS 
(Select * FROM STUDENTS B Where A.BPLACE=B.BPLACE AND A.SNO < > B.SNO) 
```

例 36 找出选修了全部课程的学生的姓名。本查询可以改为：查询这样一些学生，没有一门课程是他不选修的。
```
Select SNAME FROM STUDENTS Where NOT EXISTS 
(Select * FROM COURSES Where NOT EXISTS 
(Select * FROM ENROLLS Where ENROLLS.SNO ＝ STUDENTS.SNO AND ENROLLS.CNO= 
```

#### 关系代数运算  
例 37 设有某商场工作人员的两张表：营业员表 SP_SUBORD 和营销经理表 SP_MGR ，其关系数据模式如下： 
```
SP_SUBORD (SALPERS_ID, SALPERS_NAME, MANAGER_ID, OFFICE) 
SP_MGR (SALPERS_ID, SALPERS_NAME, MANAGER_ID, OFFICE) 
```
其中，属性 SALPERS_ID 为工作人员的编号 , SALPERS_NAME 为工作人员的姓名 , `MANAGER_ID` 为所在部门经理的编号 , `OFFICE` 为工作地点。 
(1) 若查询全部商场工作人员，可以用下面的 SQL 语句：  
```
(Select * FROM SP_SUBORD) UNION (Select * FROM SP_MGR) 
```
或等价地用下面的 SQL 语句：  
```
Select * FROM (TABLE SP_SUBORD UNION TABLE SP_MGR) 
```
(2) `INTERSECT (Select * FROM SP_SUBORD)`  
```
INTERSECT (Select * FROM SP_MGR) 
```
或等价地用下面的 SQL 语句： 
```
Select * FROM (TABLE SP_SUBORD INTERSECT TABLE SP_MGR) 
```
或用带 ALL 的 SQL 语句： 
```
(Select * FROM SP_SUBORD) INTERSECT ALL (Select * FROM SP_MGR) 
```
或 
```
Select * FROM (TABLE SP_SUBORD INTERSECT ALL TABLE SP_MGR) 
```
(3) `EXCEPT (Select * FROM SP_MGR)` 
```
EXCEPT (Select * FROM SP_SUBORD) 
```
或等价地用下面的 SQL 语句： 
```
Select * FROM (TABLE SP_MGR EXCEPT TABLE SP_ SUBORD) 
```
或用带 ALL 的 SQL 语句： 
```
(Select * FROM SP_MGR) EXCEPT ALL (Select * FROM SP_SUBORD) 
```

例 38 查询籍贯为四川、课程成绩在 80 分以上的学生信息及其成绩。（自然连接） 
```
(Select * FROM STUDENTS Where BPLACE=‘ 四川 ') NATURAL JOIN 
(Select * FROM ENROLLS Where GRADE >=80) 
```

例39 列出全部教师的姓名及其任课的课程号、班级。【外连接与外部并外连接允许在结果表中保留非匹配元组，空缺部分填以 NULL 。
外连接的作用是在做连接操作时避免丢失信息。 外连接有 3 类：   
(1)左外连接（ Left Outer Join ）:连接运算谓词为 LEFT [OUTER] JOIN ，其结果表中保留左关系的所有元组。   
(2)右外连接（ Right Outer Join ）:连接运算谓词为 RIGHT [OUTER] JOIN ，其结果表中保留右关系的所有元组。   
(3)全外连接（ Full Outer Join ）:连接运算谓词为 FULL [OUTER] JOIN ，其结果表中保留左右两关系的所有元组。】 
```
Select TNAME, CNO, CLASS FROM TEACHERS LEFT OUTER JOIN TEACHING USING (TNO) 
```

## 八、SQL 的数据操纵  
例 40 把教师李映雪的记录加入到教师表 TEACHERS 中。（插入） 
```
Insert INTO TEACHERS VALUES(1476 ， ' 李映雪 ' ， 44 ， ' 副教授 ') 
```

例 41 成绩优秀的学生将留下当教师。 
```
Insert INTO TEACHERS (TNO ， TNAME) Select DISTINCT SNO ， SNAME FROM STUDENTS ， ENROLLS 
Where STUDENTS.SNO＝ENROLLS.SNO AND GRADE ＞＝ 90 
```

例 42 把所有学生的年龄增加一岁。（修改） 
```
Update STUDENTS SET AGE ＝ AGE+1
```

例 43 学生张春明在数据库课考试中作弊，该课成绩应作零分计。 
```
Update ENROLLS SET GRADE ＝ 0 Where CNO ＝ 'C1' AND 
' 张春明 ' ＝ (Select SNAME FROM STUDENTS Where STUDENTS.SNO=ENROLLS.SNO) 
```

例 49 从教师表中删除年龄已到 60 岁的退休教师的数据。（删除） 
```
Delete FROM TEACHERS Where AGE ＞＝ 60 
```

## 九、SQL 的数据控制  
例 50 授予 LILI 有对表 STUDENTS 的查询权。（表／视图特权的授予 一个 SQL 特权允许一个被授权者在给定的数据库对象上进行特定的操作。
授权操作的数据库对象包括：表 / 视图、列、域等。授权的操作包括： Insert 、 Update 、 Delete 、 Select 、 REFERENCES 、 TRIGGER 、 
UNDER 、 USAGE 、 EXECUTE 等。其中 Insert 、 Update 、 Delete 、 Select 、 REFERENCES 、 TRIGGER 有对表做相应操作的权限，故称为表特权。） 
```
GRANT Select ON STUDENTS TO LILI WITH GRANT OPTION 
```

例 51 取消 LILI 的存取 STUDENTS 表的特权。 
```
REVOKE ALL ON STUDENTS FROM LILI CASCADE 
```


本文来自: 脚本之家[www.jb51.net](http://www.jb51.net/article/8863_3.htm)
