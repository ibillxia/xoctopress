---
layout: post
title: "05年浙大复试机试题解"
date: 2012-03-01 11:41
comments: true
categories: Program
tags: ZJU 机试 快排
---
<p>
以下是05年浙大研究生复试机试题解，感觉题目与ACM题相比，难度还相差很远，
基本上直接贴上代码了（后续年度的题解同上），
而且将整年的5道题的代码在一篇文章中贴出来。
</p>

<h3>A题：A+B （hdoj1228）（ 九度1010）</h3>
<p>水题，不解释，直接上代码：</p>
{% codeblock lang:cpp Problem A %}
#include <stdio.h> 
#include <string.h> 
char map[][8] = {"zero","one","two","three","four","five","six","seven","eight","nine"};
int cmp( char s[] ) 
{
	for( int i = 0 ; i <= 9 ; i++ )
		if( strcmp( s , map[i] ) == 0 )
			return i;
}
int main() 
{
	char s[8];
	int a,b;
	while(1) 
	{
		a = 0;
		while(scanf("%s",s)&&strcmp(s,"+")!=0)
			a = 10*a + cmp(s);
		b = 0;
		while(scanf("%s",s)&&strcmp(s,"=")!=0)
			b = 10*b + cmp(s);
		if( a == 0 && b == 0 ) break;
		printf( "%d\n" , a+b );
	}
	return 1;
}
{% endcodeblock %}

<!-- more -->
<h3>B题：最大连续子序列 (hdoj1231)（ 九度 1011 ）</h3>
<p>这道题做过很多遍了，但用过的最好的方法还是用二重循环，在OJ上难免TLE了。
Google了下才知道，可以用DP在O(N)内实现，代码如下：</p>
{% codeblock lang:cpp Problem B %}
#include<stdio.h> 
int main() 
{
	int k,d[10000];
	int i,j,sum,max,st,end,cnt;
	while(1)
	{
		scanf("%d",&k);
		if(k==0)break;
		for(i=0;i<k;i++,getchar())
			scanf("%d",d+i);
		cnt=0;
		for(i=0;i<k;i++)
			if(d[i]<0) cnt++;
			else break;
		if(cnt==k)
		{
			printf("%d %d %d\n",0,d[0],d[k-1]);
			continue;
		}
		st=end=j=sum=0;
		max=d[0];
		for(i=0;i<k;i++)
		{
			j=sum>0 ? j:i;
			sum = sum>0 ? sum : 0;
			sum+=d[i];
			if(sum>max)
			{
				max=sum;
				st=j;
				end=i;
			}
		}
		printf("%d %d %d\n",max,d[st],d[end]);
	}
	return 0;
}
{% endcodeblock %}

<h3>C题：畅通工程 (hdoj1232)（ 九度 1012）</h3>
<p>以前很少做图论的题，看到这题时，首先想到的就是用BFS，计算遍历完所有点所需要BFS的次数，
该次数减一即为所求，但提交后发现TLE了。查了下资料才知道，要使用并查集，以前没用过，
总以为这是STL中的东西，而STL也没学过，不会，于是乎继续想办法改进基于BFS的算法，
悲剧的是一直TLE，最后还是看了下并查集的知识，才发现用C数组很容易就可以实现。
使用了并查集后，果断AC了，呵呵。代码如下：</p>

{% codeblock lang:cpp Problem C %}
#include <stdio.h> 
#include <memory.h> 
int m,n,min,set[1002];
int Find(int x)
{
	while(x!=set[x])
		x=set[x];
	return x;
}
void Union(int a,int b)
{
	int t1,t2;
	t1=Find(a);
	t2=Find(b);
	if(t1!=t2)
	{
		set[t2]=t1;
		min--;
	}
}
int main() 
{
	int i,a,b;
	while(1)
	{
		scanf("%d",&n);
		if(n==0) break;
		for(i=0;i<=n;i++) set[i]=i;
		min=n-1;
		scanf("%d",&m);
		for(i=0;i<m;i++)
		{
			scanf("%d %d",&a,&b);
			Union(a,b);
		}
		if(min>0)printf("%d\n",min);
		else printf("0\n");
	}
	return 0;
}
{% endcodeblock %}

<h3>D题：开门人和关门人(hdoj1234)（ 九度 1013）</h3>
<p>水题，直接上代码：</p>
{% codeblock lang:cpp Problem D %}
#include <stdio.h> 
#include <memory.h> 
int m,n; char temp[16],first[16],last[16];
int time[3],min,max;
int main() 
{
	int i,j;
	scanf("%d",&n);
	for(i=0;i<n;i++)
	{
		scanf("%d",&m);
		min=86400;
		max=-1;
		for(j=0;j<m;j++)
		{
			scanf("%s",temp);
			scanf("%d:%d:%d",time,time+1,time+2);
			time[0]=time[0]*3600+time[1]*60+time[2];
			if(time[0]<min)
			{
				min=time[0];
				memcpy(first,temp,sizeof(temp));
			}
			scanf("%d:%d:%d",time,time+1,time+2);
			time[0]=time[0]*3600+time[1]*60+time[2];
			if(time[0]>max)
			{
				max=time[0];
				memcpy(last,temp,sizeof(temp));
			}
		}
		printf("%s %s\n",first,last);
	}
	return 0;
}
{% endcodeblock %}

<h3>E题：排名(hdoj1236)（ 九度 1014）</h3>
<p>简单题，直接调用系统的快排函数，代码如下：</p>
{% codeblock lang:cpp Problem E %}
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
typedef struct student {
	char name[21];
	int score;
}stu;
int m,n,g,fz[10];
stu st[1000];
int cmp(const void * a,const void * b)
{
	int t=(*(stu*)b).score-(*(stu*)a).score;
	if(t!=0)return t;
	else return strcmp((*(stu*)a).name,(*(stu*)b).name);
}
int main() 
{
	int i,j,t,ts,ss;
	while(1)
	{
		scanf("%d",&n);
		if(0==n)break;
		scanf("%d %d",&m,&g);
		for(i=0;i<m;i++)
			scanf("%d",&fz[i]);
		for(i=0;i<n;i++)
		{
			scanf("%s",&(st[i].name));
			scanf("%d",&t);
			ss=0;
			for(j=0;j<t;j++)
			{
				scanf("%d",&ts);
				ss+=fz[ts-1];
			}
			if(ss<g)
			{
				n--;
				i--;
			}
			else
				st[i].score=ss;
		}
		qsort(st,n,sizeof(stu),cmp);
		printf("%d\n",n);
		for(i=0;i<n;i++)
		printf("%s %d\n",st[i].name,st[i].score);
	}
	return 0;
}
{% endcodeblock %}

<p>小结：总的来说，05年的题不是太难，但由于很久没写代码，所以做的不是很顺。</p>

