---
layout: post
title: "08年浙大复试机试题解"
date: 2012-03-04 22:42
comments: true
categories: Program
tags: ZJU 机试 Prim 动态规划
---
<p>
08年浙大研究生复试机试题解
</p>

<h3>A题：又一版A+B（hdoj1877）（九度1026）</h3>
<p>水题，直接上代码：</p>

{% codeblock lang:cpp Problem A %}
#include <stdio.h>
char out[34];
unsigned int m,a,b,c;
int main()
{
    int i;
    while(scanf("%d",&m)&&m!=0){
        scanf("%d %d",&a,&b);
        c=a+b;
        if(c==0){printf("0\n");continue;}
        i=0;
        while(c){
            out[i++]=c%m;
            c/=m;
        }
        while(i)
            printf("%d",out[--i]);
        printf("\n");
    }
    return 0;
}
{% endcodeblock %}

<!-- more -->
<h3>B题：欧拉回路（hdoj1878）（九度1027）</h3>
<p>对于无向图，存在欧拉回路的条件是：图连通，顶点的度为偶数。
对于有向图，存在欧拉回路的条件是：图强连通，顶点的入度等于出度。代码如下：</p>

{% codeblock lang:cpp Problem B %}
#include <stdio.h>
#include <memory.h>
int m,n,v[1000],g[1000][1000];
int main()
{
    int i,j,a,b;
    while(scanf("%d",&n)&&n!=0){
        scanf("%d",&m);
        memset(v,0,sizeof(v));
        memset(g,0,sizeof(g));
        for(i=0;i<m;i++){
            scanf("%d %d",&a,&b);
            g[a-1][b-1]=g[b-1][a-1]=1;
            v[a-1]++;v[b-1]++;
        }
        if(m<n){printf("0\n");continue;}
        for(i=0;i<n;i++)if(v[i]%2)break;  //判断度是否为偶数
        if(i<n)printf("0\n");
        else{  //DFS判断图是否连通
            memset(v,0,sizeof(v));
            v[0]=1;j=0;
            for(i=0;i<n;i++){
                if(!v[i] && g[j][i]){
                    v[i]=1;j=i;i=0;
                }
            }
            for(i=0;i<n;i++)
                if(!v[i]){printf("0\n");break;}
            if(i==n)printf("1\n");
        }
    }
    return 0;
}
{% endcodeblock %}

<h3>C题：继续畅通工程（hdoj1879）（九度1028）</h3>
<p>模板题，prim算法</p>

{% codeblock lang:cpp Problem C %}
#include <stdio.h>
#include <memory.h>
#define INF 0x1fffffff
int n,g[100][100];
int main()
{
    int i,j,a,b,c,d;
    int low[100],v[100],t,min,sum;
    while(scanf("%d",&n)&&n!=0){
        for(i=0;i<n;i++)
            for(j=0;j<n;j++)g[i][j]=g[j][i]=INF;
        for(i=0;i<n;i++)g[i][i]=0;
        for(i=0;i<n;i++)
            for(j=i+1;j<n;j++){
                scanf("%d %d %d %d",&a,&b,&c,&d);
                a--;b--;
                if(d==1)g[a][b]=g[b][a]=0;
                else if(g[a][b]>c)g[a][b]=g[b][a]=c;
            }
        memset(v,0,sizeof(v));
        for(i=1;i<n;i++)low[i]=g[0][i];
        v[0]=1;
        sum=0;
        for(i=1;i<n;i++){
            t=-1;min=INF;
            for(j=0;j<n;j++)
                if(!v[j]&&min>low[j]){min=low[j];t=j;}
            sum+=min;
            v[t]=1;
            for(j=0;j<n;j++)
                if(!v[j]&&low[j]>g[t][j])low[j]=g[t][j];
        }
        printf("%d\n",sum);
    }
    return 0;
}
{% endcodeblock %}

<h3>D题：魔咒词典（hdoj1880）（九度1029）</h3>
<p>水题，字符串处理，注意不需要排序，不然会超时。</p>
{% codeblock lang:cpp Problem D %}
#include <stdio.h>
#include <string.h>
typedef struct node{
    char name[24];
    char func[82];
}record;
char s[108];
record dict[100000];
int main()
{
    int i,j,m,n,t;
    char *p;
    i=0;
    while(gets(s) && strcmp(s,"@END@")){
        p=strchr(s,']');
        strncpy(dict[i].name,s,p-s+1);
        strcpy(dict[i].func,p+2);
        i++;
    }
    m=i;
    scanf("%d",&n);
    getchar();
    for(i=0;i<n;i++){
        gets(s);
        if(s[0]=='['){
            for(j=0;j<m;j++)
                if(!strcmp(s,dict[j].name)){printf("%s\n",dict[j].func);break;}
        }else{
            for(j=0;j<m;j++)
                if(!strcmp(s,dict[j].func)){
                    t=strlen(dict[j].name);
                    strcpy(s,dict[j].name+1);
                    s[t-2]=0;
                    printf("%s\n",s);break;
                }
        }
        if(j==m)printf("what?\n");
    }
    return 0;
}
{% endcodeblock %}

<h3>E题：毕业bg（hdoj1881）（九度1030）</h3>
<p>可看做背包问题，将截止时间看做背包的容量，将bg看做重物，构建DP状态方程。代码如下：</p>

{% codeblock lang:cpp Problem E %}
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#define MAX(a,b) (a)>(b) ? (a) : (b)
int n,d[32][3],m[32][2000];
int cmp(const void *a,const void *b){
    return ((int*)a)[2]-((int*)b)[2];
}
int main()
{
    int i,j,tm,mh;
    while(scanf("%d",&n) && n>=0){
        if(n==0)continue;
        tm=0;
        for(i=0;i<n;i++){
            scanf("%d %d %d",d[i],d[i]+1,d[i]+2);
            if(tm<d[i][2])tm=d[i][2];
        }
        qsort(d,n,sizeof(d[0]),cmp);
        memset(m,0,sizeof(m));
        mh=-1;
        for(i=1;i<=n;i++)
            for(j=0;j<=tm;j++){
                if(j<=d[i-1][2]&&j>=d[i-1][1])
                    m[i][j]=MAX(m[i-1][j],m[i-1][j-d[i-1][1]]+d[i-1][0]);
                else
                    m[i][j]=m[i-1][j];
                if(m[i][j]>mh)mh=m[i][j];
            }
        printf("%d\n",mh);
    }
    return 0;
}
{% endcodeblock %}

<p>小结：个人感觉毕业bg有点小难，主要是以前做过的背包问题太少，思维没有转换过来。
其余的题基本都很水。</p>

