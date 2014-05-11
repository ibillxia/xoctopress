---
layout: post
title: "06年浙大复试机试题解"
date: 2012-03-02 12:12
comments: true
categories: Program
tags: ZJU ProgramTest Prim Stack
---
<p>
06年浙大研究生复试机试题解
</p>

<h3>A题：还是A+B（hdoj1229）（九度1015）</h3>
<p>水题，简直水得不能再水</p>
{% codeblock Problem A %}
#include <stdio.h>
#include <string.h>
int main()
{
    int a,b,k,t;
    while(1){
        scanf("%d %d %d",&a,&b,&k);
        if(a==0&&b==0) return 0;
        t=1;
        while(k--)t*=10;
        if(a%t==b%t)printf("%d\n",-1);
        else printf("%d\n",a+b);
    }
}
{% endcodeblock %}

<!-- more -->
<h3>B题：火星A+B（hdoj1230）（九度1016）</h3>
<p>不是很难，注意判断输出的首位是否为零，如果为零，就不要输出（除非结果为0）。
虽然不难，但九度居然将其标为五星题，表示很费解。
代码如下：
</p>
{% codeblock Problem B %}
#include<stdio.h>
int d[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101};
int main()
{
    int a[25],b[25],c[26],al,bl,t;
    while(1){
        al=bl=0;
        while(scanf("%d",a+al++)&&getchar()!=' ');
        while(scanf("%d",b+bl++)&&getchar()==',');
        if(a[0]==0&&b[0]==0)break;
        t=0;c[0]=0;
        while(al>0&&bl>0){
            al--;bl--;
            c[t+1]=(a[al]+b[bl]+c[t])/d[t];
            c[t]=(a[al]+b[bl]+c[t])%d[t];
            t++;
        }
        while(al>0){
            al--;
            c[t+1]=(a[al]+c[t])/d[t];
            c[t]=(a[al]+c[t])%d[t];
            t++;
        }
        while(bl>0){
            bl--;
            c[t+1]=(b[bl]+c[t])/d[t];
            c[t]=(b[bl]+c[t])%d[t];
            t++;
        }
        if(c[t]==0) t--;
        while(t>0)
            printf("%d,",c[t--]);
        printf("%d\n",c[0]);
    }
    return 0;
}
{% endcodeblock %}

<h3>C题：还是畅通工程（hdoj1233）（九度1017）</h3>
<p>模板题，prim算法，代码如下：</p>

{% codeblock Problem C %}
#include <stdio.h>
#include <memory.h>
#define INF 0x7fffffff
int n,d[100][100];
int prim(){
    int i,j,t,sum,min,vis[100],low[100];
    memset(vis,0,sizeof(vis));
    vis[0]=1;
    sum=0;
    low[0]=INF;
    for(i=1;i<n;i++) low[i]=d[0][i];
    for(i=1;i<n;i++){
        t=-1;min=INF;
        for(j=0;j<n;j++)
            if(!vis[j] && min>low[j]){
                t=j;min=low[j];
            }
        vis[t]=1;
        sum+=min;
        for(j=0;j<n;j++)
            if(!vis[j] && d[t][j]<low[j]){
                low[j] = d[t][j];
            }
    }
    return sum;
}
int main()
{
    int i,j,from,to,dis,min;
    while(1){
        scanf("%d",&n);
        if(0==n)break;
        for(i=0;i<n;i++)d[i][i]=INF;
        j=(n*(n-1))>>1;
        for(i=0;i<j;i++){
            scanf("%d %d %d",&from,&to,&dis);
            d[from-1][to-1]=d[to-1][from-1]=dis;
        }
        min = prim();
        printf("%d\n",min);
    }
    return 0;
}
{% endcodeblock %}

<h3>D题：统计同成绩学生人数（hdoj1235）（九度1018）</h3>
<p>水题，同样很水，代码如下：</p>
{% codeblock Problem D %}
#include <stdio.h>
int n,d[1001],t,cnt;
int main()
{
    int i;
    while(1){
        scanf("%d",&n);
        if(0==n)break;
        for(i=0;i<n;i++)
            scanf("%d",d+i);
        scanf("%d",&t);
        cnt=0;
        for(i=0;i<n;i++)
            if(d[i]==t)cnt++;
        printf("%d\n",cnt);
    }
    return 0;
}
{% endcodeblock %}

<h3>E题：简单计算器（hdoj1237）（九度1019）</h3>
<p>有一点难度，但如果对此比较有研究，就不难了。
主要思路是利用栈，得到表达式的逆波兰式，再进行计算，代码如下：</p>
{% codeblock Problem E %}
#include <stdio.h>
#include <string.h>
char in[202],cstk[80];
int ct,dt;
double dstk[80];
int cmp(char c1,char c2){
    int i,a[2];
    char c[2];
    c[0]=c1;
    c[1]=c2;
    for(i=0;i<2;i++){
        switch(c[i]){
            case '+':
            case '-':
                a[i]=1;
                break;
            case '*':
            case '/':
                a[i]=2;
                break;
        }
    }
    return a[0]-a[1];
}
double cal(double da,double db,char ch){
    switch(ch){
        case '+':return db+da;
        case '-':return db-da;
        case '*':return db*da;
        case '/':return db/da;
    }
}
int main()
{
    char c1,c2;
    int len,i,a;
    double da,db,dc;
    while(1){
        gets(in);
        len = strlen(in);
        if(1==len && in[0]=='0')break;
        ct=dt=0;
        for(i=0;i<len;i++){
            a=0;
            while(in[i]>='0'&&in[i]<='9')
                a=a*10+(in[i++]-'0');
            dstk[dt++]=(double)a;
            i++;
            if(i<len)cstk[ct++]=in[i];
            i++;
        }
        for(i=0;i<dt/2;i++){
            da=dstk[i];
            dstk[i]=dstk[dt-i-1];
            dstk[dt-i-1]=da;
        }
        for(i=0;i<ct/2;i++){
            c1=cstk[i];
            cstk[i]=cstk[ct-i-1];
            cstk[ct-i-1]=c1;
        }
        while(ct){
            da=dstk[--dt];
            db=dstk[--dt];
            c1=cstk[--ct];
            if(ct>0){
                c2=cstk[ct-1];
                if(cmp(c1,c2)>=0){
                    dstk[dt++]=cal(db,da,c1);
                }else{
                    dc=dstk[--dt];
                    c2=cstk[--ct];
                    dstk[dt++]=cal(dc,db,c2);
                    dstk[dt++]=da;
                    cstk[ct++]=c1;
                }
            }else{
                dstk[dt++]=cal(db,da,c1);
            }
        }
        printf("%.2f\n",dstk[0]);
    }
    return 0;
}
{% endcodeblock %}

<p>小结：总体而言不是很难，主要是水题很水，而难点的题也不是很难，稍微耐心、细心点，就能AC了。</p>

