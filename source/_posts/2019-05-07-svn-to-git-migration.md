---   
layout: post   
title: "SVN迁移到Git的过程与技巧"   
date: 2019-05-07 09:49   
comments: true   
categories: Program   
tags: Git SVN 版本控制   
---   

关于在VCS中SVN和Git之间的迁移（Clone）这个部分网上已经有大批的文章介绍，而且都非常不错，能够满足我们的常见的需求，这里介绍的是我自己整理的一些技巧和使用中出现的一些问题和疑问。

阅读本篇文章，请先有一些Git和SVN的使用经验（又是经验，经验到底是什么？我都不知道）。

# 一、基础迁移：分支和tags同步

今天的实验对象是，把 [http://code.google.com/p/jdbcdslog-exp/](http://code.google.com/p/jdbcdslog-exp) 这个使用SVN管理的project迁移到 Git上面，Git托管网站选择github。SVN迁移到Git，当然要清楚git svn 命令了。

首先请在github上面创建一个repository，这个简单，就不说了，然后就是使用强大的git了。

```
$ git svn init https://jdbcdslog-exp.googlecode.com/svn/ -s   
$ git svn fetch  
```

<!--more-->

当然上面的两步，可以作一步处理

```
$ git svn clone https://jdbcdslog-exp.googlecode.com/svn/ -s  
```

注： -s 参数是表面使用的是svn标准命名方法，即 trunk，tags，branches，这个参数有时很重要，建议使用，命令后面还可以加个文件夹名字作为clone后的目录，如果没有默认是当前路径。

git svn fetch 这个步骤，可能碰到只想从某个版本开始进行fetch，那么请需要–r 参数。

例如：

```
$ git svn fetch -r 1342:HEAD  
```

注：1342是你想要从这个版本开始fetch，如何查看这个版本号，你可以使用 svn 命令（windows下需要安装Subversion Client，e.g. sliksvn），简单使用就是 svn log svn_url ,这个时候，你可能看到整屏在刷新，没关系，看到log就行。当然更简单的就是使用TortoiseSVN-> Show log。

亦或者你可以这样使用：

```
$ git svn clone https://jdbcdslog-exp.googlecode.com/svn/ -sr 1342:HEAD jdbcdslog-exp  
```

到这步的时候，本地已经clone了SVN仓库，现在需要的就是提交到远程了。首先，关联github远程仓库，如下：

```
$ git remote add origin git@github.com:usc/jdbcdslog-exp.git  
```

普通青年这个时候，肯定就会选择使用

```
$ git push -u origin master  
```

到github上面查看这个仓库(repository),大致效果如下 [https://github.com/usc/jdbcdslog-exp](https://github.com/usc/jdbcdslog-exp)

<center>{% img /images/2019/IMAG2019050701.png %}</center><br>

二逼青年当然要看看文档或者仓库信息，有没有什么值得注意的，你瞧瞧，出现了很多branches，并没有tag（SVN仓库目录是标准目录，其中tags下有几个版本的代码，而branches下是没有代码的），是不是很奇怪（上图实际上也说明了一些问题，只有一个branches），既然出现了这样，就要想办法解决了。

<center>{% img /images/2019/IMAG2019050702.png %}</center><br>

问题的解决直接来自《Pro Git》电子书，下面一段copy自《Pro Git》。

你还需要一点post-import（导入后）清理工作。最起码的，应该清理一下git svn 创建的那些怪异的索引结构。首先要移动标签，把它们从奇怪的远程分支变成实际的标签，然后把剩下的分支移动到本地。

要把标签变成合适的Git 标签，运行

```
$ cp -Rf .git/refs/remotes/tags/\* .git/refs/tags/
$ rm -Rf .git/refs/remotes/tags  
```

该命令将原本以tag/ 开头的远程分支的索引变成真正的（轻巧的）标签。

接下来，把refs/remotes 下面剩下的索引变成本地分支：

```
$ cp -Rf .git/refs/remotes/\* .git/refs/heads/
$ rm -Rf .git/refs/remotes   
```

现在所有的旧分支都变成真正的Git 分支，所有的旧标签也变成真正的Git 标签。最后，一项工作就是把新建的Git 服务器添加为远程服务器并且向它推送。为了让所有的分支和标签都得到上传，我们使用这条命令：

```
$ git push origin –all  
```

所有的分支和标签现在都应该整齐干净的躺在新的Git 服务器里了。

【引用完毕】

上面最后部分（git push origin –all），我运行发现有些问题的，并不能如它所说，分支和标签(branches and tags)都在git服务器中，请看下面截图：

<center>{% img /images/2019/IMAG2019050703.jpg %}</center><br>

<center>{% img /images/2019/IMAG2019050704.png %}</center><br>

实际上，只提交了branches到github上面，并没有提交tags，当然，很简单，你可以使用 git push –h 查看下帮助，就会发现，你应该知道怎么做了，使用git push –tags就可以了。

<center>{% img /images/2019/IMAG2019050705.png %}</center><br>

（使用git push –tags效果）

<center>{% img /images/2019/IMAG2019050706.png %}</center><br>

为了完整，还是说说文艺青年吧。文艺青年还需要搞技术吗？当然是找个上面的普通青年或者二逼青年就搞定了。

# 二、进阶迁移：commit logs和ignores

到此，任务已经差不多完成了，之所以说差不多了，是因为在《Pro Git》发现了两个更让人遗忘的技巧。

## 第一, Log中的信息（主要是作者）

请看完成上面步骤后产生的git log，会是如何

<center>{% img /images/2019/IMAG2019050707.png %}</center><br>

《Pro Git》上面也有说明，需要先把作者信息抓取出来，写到一个文件(假如是user.txt，放在git 当前目录下)中，

```
git svn clone https://jdbcdslog-exp.googlecode.com/svn/ -sr 1342:HEAD --authors-file=user.txt --no-metadata jdbcdslog   
```

再来看看效果

<center>{% img /images/2019/IMAG2019050708.jpg %}</center><br>

## 第二，git ignores

【下面来自《Pro Git》第八章】

假如克隆了一个包含了svn:ignore 属性的Subversion 仓库，就有必要建立对应的.gitignore 文件来防止意外提交一些不应该提交的文件。git svn 有两个有益于改善该问题的命令。第一个是git svn create-ignore，它自动建立对应的.gitignore 文件，以便下次提交的时候可以包含它。

第二个命令是git svn show-ignore，它把需要放进.gitignore 文件中的内容打印到标

准输出，方便我们把输出重定向到项目的黑名单文件：

```
$ git svn show-ignore > .git/info/exclude  
```

这样一来，避免了.gitignore 对项目的干扰。如果你是一个Subversion 团队里唯一的

Git 用户，而其他队友不喜欢项目包含.gitignore，该方法是你的不二之选。

【引用结束】

# 三、SVN和Git的并行

现在代码即在SVN(google code)上面托管着，也在Git(github)上面托管着，当然提交代码的时候，就需要注意点点。代码的提交大致会有两种情况，提交到SVN还是Git。

- 提交到SVN

开发以SVN为主，大部分Members 都使用SVN，那么如果你使用Git管理你的代码，那么如何同步到SVN上面了？很简单，使用下面命令就可以了，

```
$ git svn rebase
$ git svn dcommit   
```

原则和SVN提交差不多，先更新后提交（个人总结）

- 提交到Git

如果想提交到Git上面，当然先要拉取SVN Repo最新的代码，当你push的时候，你可能就会发现有些问题，

<center>{% img /images/2019/IMAG2019050709.jpg %}</center><br>

根据提示，你可以很容易就知道如何处理，实际上，这也是git方便的地方，很多时候，提示 + -h 都能搞定问题。好了，整个步骤如下:

```
$ git svn rebase
$ git pull
$ git commit –am "xxx"
$ git push  
```

# 四、其他补充

随着Project的开发，可能SVN URL改变了（很多原因，比如域名改变，比如版本升级，再比如一不小心使用了http，想换到https等），那么如果使用SVN，很简单，直接relocate就可以了，但是以前同步使用的Git Project如何跟着变化了，上网查了一下，发现比较有效的来自下面。

[https://git.wiki.kernel.org/articles/g/i/t/GitSvnSwitch_8828.html](https://git.wiki.kernel.org/articles/g/i/t/GitSvnSwitch_8828.html)

【引用开始】

General Case

What immediately sprang to mind, and what was suggested e.g. on the mailing list, was to simply edit your .git/config, and change the url= in the section [svn-remote "svn"]. That doesn't work, however. Instead, I found several suggestions to use variations of this theme:

- Edit the svn-remote url URL in .git/config to point to the new domain name

- Run git svn fetch - <span style="color: red">This needs to fetch at least one new revision from svn!</span>

- Change svn-remote url back to the original url

- Run git svn rebase -l to do a local rebase (with the changes that came in with the last fetch operation)

- Change svn-remote url back to the new url

- Run git svn rebase should now work again!

This will only work, if the git svn fetch step actually fetches anything! (Took me a while to discover that... I had to put in a dummy revision to our svn repository to make it happen!)

【引用结束】

注：红色部分请注意下。

本人已经验证这个方法是可以成功切换SVN URL的。

如果想更了解清楚，请参考《Pro Git》第八章——Git 与其他系统。实际上这些内容，全部在《Pro Git》一书中，以前也没仔细阅读，现在发现，它不仅提供了基础知识，而且还想到了我们会出现困难或者疑问的地方，并给出了解决办法或思路。

碰到问题再想着解决，这种“需求驱动学习”的方式是最能让你铭记的。

如果有兴趣的话，后面可以介绍下，在不同的google code project中进行同步（sync）或者备份（SVN迁移到SVN）。

# 参考

[http://progit.org/book/](http://progit.org/book/)

[http://progit.org/book/zh/](http://progit.org/book/zh/)

[SVN+GIT=鱼与熊掌兼得](http://rubynroll.iteye.com/blog/203133)

[git svn实战](http://www.ooso.net/archives/576)

[如何在svn系统中使用git](http://www.robinlu.com/blog/archives/194)

[小试git-svn](http://bigwhite.blogbus.com/logs/100700290.html)

[https://git.wiki.kernel.org/articles/g/i/t/GitSvnSwitch_8828.html](https://git.wiki.kernel.org/articles/g/i/t/GitSvnSwitch_8828.html)


原文链接： [SVN迁移到Git的过程（+ 一些技巧）](http://www.blogjava.net/lishunli/archive/2012/01/15/368562.html)

