---
layout: post
title: "07年浙大复试机试题解"
date: 2012-03-03 22:05
comments: true
categories: Program
tags: ZJU 机试 快排 Prim 动态规划
---
<p>
07年浙大研究生复试机试题解
</p>

<h3>A题：最小长方形（hdoj1859）（九度1020）</h3>
<p>水题，不解释，代码如下：</p>
{% codeblock lang:cpp Problem A %}
#include <stdio.h>
int main()
{
    int lx,ly,rx,ry,tx,ty;
    while(1){
        scanf("%d %d",&tx,&ty);
        if(tx==0&&ty==0)break;
        lx=rx=tx;
        ly=ry=ty;
        while(1){
            scanf("%d %d",&tx,&ty);
            if(tx==0&&ty==0)break;
            if(tx<lx)lx=tx;
            if(ty<ly)ly=ty;
            if(tx>rx)rx=tx;
            if(ty>ry)ry=ty;
        }
        printf("%d %d %d %d\n",lx,ly,rx,ry);
    }
    return 0;
}
{% endcodeblock %}

<!-- more -->
<h3>B题：统计字符（hdoj1860）（九度1021）</h3>
<p>继续水题，代码如下：</p>
{% codeblock lang:cpp Problem B %}
#include <stdio.h>
#include <string.h>
#include <memory.h>
int main()
{
    char s[6],str[82];
    int i,j,cnt[5],len;
    while(1){
        gets(s);
        len=strlen(s);
        if(len==1&&s[0]=='#')break;
        gets(str);
        memset(cnt,0,sizeof(cnt));
        for(j=0;str[j];j++){
            for(i=0;i<len;i++)
                if(str[j]==s[i])cnt[i]++;
        }
        for(i=0;i<len;i++)
            printf("%c %d\n",s[i],cnt[i]);
    }
    return 0;
}
{% endcodeblock %}

<h3>C题：游船出租（hdoj1861）（九度1022）</h3>
<p>模拟题，水题。代码如下：</p>

{% codeblock lang:cpp Problem C %}
#include <stdio.h>
#include <memory.h>
int d[101],f[101];
int main()
{
    char ch;
    int n,t1,t2,cnt,sum;
    cnt=sum=0;
    memset(d,0,sizeof(d));
    memset(f,0,sizeof(f));
    while(scanf("%d",&n) && n!=-1){
        if(n==0){
            scanf(" %c %d:%d",&ch,&t1,&t2);
            if(cnt==0)printf("0 0\n");
            else printf("%d %d\n",cnt,(int)(sum*1.0/cnt+0.5));
            cnt=sum=0;
            memset(d,0,sizeof(d));
            memset(f,0,sizeof(f));
        }else{
            scanf(" %c %d:%d",&ch,&t1,&t2);
            if(ch=='S'){d[n]=t1*60+t2;f[n]=1;}
            else if(f[n]){
                sum+=t1*60+t2-d[n];
                cnt++;
                f[n]=0;
            }
        }
    }
    return 0;
}
{% endcodeblock %}

<h3>D题：Excel排序（hdoj1862）（九度1023）</h3>
<p>排序题，水题，直接上代码：</p>

{% codeblock lang:cpp Problem D %}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct student{
    char num[7];
    char name[9];
    int score;
}student;
int n;
student stu[100000];
int cmp1(const void *a,const void *b){
    return strcmp((*(student*)a).num,(*(student*)b).num);
}
int cmp2(const void *a,const void *b){
    int t=strcmp((*(student*)a).name,(*(student*)b).name);
    if(t!=0)return t;
    else return strcmp((*(student*)a).num,(*(student*)b).num);
}
int cmp3(const void *a,const void *b){
    int t=(*(student*)a).score-(*(student*)b).score;
    if(t!=0)return t;
    else return strcmp((*(student*)a).num,(*(student*)b).num);
}
int main()
{
    int i,c,cnt;
    cnt=0;
    while(scanf("%d %d",&n,&c)){
        if(n==0)break;
        cnt++;
        for(i=0;i<n;i++)
            scanf("%s %s %d",stu[i].num,stu[i].name,&stu[i].score);
        switch(c){
            case 1: qsort(stu,n,sizeof(stu[0]),cmp1);break;
            case 2: qsort(stu,n,sizeof(stu[0]),cmp2);break;
            case 3: qsort(stu,n,sizeof(stu[0]),cmp3);break;
        }
        printf("Case %d:\n",cnt);
        for(i=0;i<n;i++)
            printf("%s %s %d\n",stu[i].num,stu[i].name,stu[i].score);
    }
    return 0;
}
{% endcodeblock %}

<h3>E题：畅通工程（hdoj1863）（九度1024）</h3>
<p>模板题，prim算法</p>

{% codeblock lang:cpp Problem E %}
#include <stdio.h>
#include <memory.h>
#define INF 0x7fffffff
int m,n,cost[100][100];
int solve(void){
    int i,j,t,min,rt,vd[100],low[100];
    memset(vd,0,sizeof(vd));
    rt=0;
    vd[0]=1;
    for(i=0;i<m;i++)low[i]=cost[0][i];
    for(i=1;i<m;i++){
        min=INF;
        t=-1;
        for(j=0;j<m;j++)
            if(!vd[j]&&min>low[j])min=low[t=j];
        if(INF==min)return -1;
        rt+=min;
        vd[t]=1;
        for(j=0;j<m;j++)
            if(!vd[j]&&low[j]>cost[t][j])low[j]=cost[t][j];
    }
    return rt;
}
int main()
{
    int i,j,a,b,c,min;
    while(1){
        scanf("%d %d",&n,&m);
        if(0==n)break;
        for(i=0;i<100;i++)
            for(j=0;j<100;j++)
                cost[i][j]=INF;
        for(i=0;i<n;i++){
            scanf("%d %d %d",&a,&b,&c);
            cost[a-1][b-1]=cost[b-1][a-1]=c;
        }
        min=solve();
        if(min==-1)printf("?\n");
        else printf("%d\n",min);
    }
    return 0;
}
{% endcodeblock %}

<h3>F题：最大报销额（hdoj1864）（九度1025）</h3>
<p>典型的背包问题，DP</p>

{% codeblock lang:cpp Problem F %}
#include <stdio.h>
#define PRE 0.0001
int main()
{
    char tp;
    int i,j,n,m,cnt,flag;
    double t,q,tt[3],sum[30],max,st[30][30];
    while(scanf("%lf %d",&q,&n)&&n!=0){
        max=cnt=0;
        for(i=0;i<n;i++){
            sum[cnt]=tt[0]=tt[1]=tt[2]=flag=0;
            scanf("%d",&m);
            while(m--){
                scanf(" %c:%lf",&tp,&t);
                if(flag)continue;
                tp=tp-'A';
                if(tp>=0&&tp<3){
                    tt[tp]+=t;sum[cnt]+=t;
                    if((tt[tp]-600.0)>PRE || (sum[cnt]-1000.0)>PRE)flag=1;
                }else flag=1;
            }
            if(flag||sum[cnt]>q)continue;
            cnt++;
        }
        for(i=0;i<cnt;i++)
            for(j=0;j<cnt;j++)
                if(sum[i]<sum[j]){
                    t=sum[i];
                    sum[i]=sum[j];
                    sum[j]=t;
                }
        max=0;
        for(i=0;i<cnt;i++){
            st[i][i]=sum[i];
            for(j=i+1;j<cnt;j++)
                if(st[i][j-1]+sum[j]<=q)st[i][j]=st[i][j-1]+sum[j];
                else st[i][j]=st[i][j-1];
            if(st[i][j-1]>max)max=st[i][j-1];
            if(q-max<PRE)break;
        }
        printf("%.2f\n",max);
    }
    return 0;
}
{% endcodeblock %}

<p>小结：07年水题也比较多，题目基本都比较基础，除了水题剩下的就都是模板题。</p>

