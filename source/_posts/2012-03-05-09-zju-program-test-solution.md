---
layout: post
title: "09年浙大复试机试题解"
date: 2012-03-05 16:48
comments: true
categories: Program
tags: ZJU 机试 DFS
---
<p>
09年浙大研究生复试机试题解
</p>

<h3>A题：xxx定律（hdoj3782）（九度1031）</h3>
<p>水题，直接上代码：</p>

{% codeblock lang:cpp Problem A %}
#include <stdio.h>
int main()
{
    int n,cnt;
    while(scanf("%d",&n)&&n!=0){
        if(n==1){printf("0\n");continue;}
        cnt=0;
        while(n!=1){
            if(n%2)n=(3*n+1)>>1;
            else n=n>>1;
            cnt++;
        }
        printf("%d\n",cnt);
    }
    return 0;
}
{% endcodeblock %}

<!-- more -->
<h3>B题：ZOJ（hdoj3783）（九度1032）</h3>
<p>继续水题</p>
{% codeblock lang:cpp Problem B %}
#include <stdio.h>
char s[102];
int main()
{
    int i,z,o,j;
    while(scanf("%s",s)){
        if(s[0]=='E')break;
        z=o=j=0;
        for(i=0;s[i]!=0;i++){
            switch(s[i]){
                case 'Z':z++;break;
                case 'O':o++;break;
                case 'J':j++;break;
            }
        }
        while(i){
            if(z){printf("Z");z--;}
            if(o){printf("O");o--;}
            if(j){printf("J");j--;}
            i--;
        }
        printf("\n");
    }
    return 0;
}
{% endcodeblock %}

<h3>C题：继续xxx定律（hdoj3784）（九度1033）</h3>
<p>题目不是很好懂，但只要认真看题目，还是不是很难的，值得注意的是，
如果在前面是关简数，而后面却是作为覆盖数的数，一律当做覆盖数而不是关键数。
代码如下：</p>

{% codeblock lang:cpp Problem C %}
#include <stdio.h>
#include <memory.h>
int n,a[510];
char b[1002];
int main()
{
    int i,t;
    while(scanf("%d",&n)!=EOF){
        if(n==0)continue;
        memset(a,0,sizeof(a));
        memset(b,0,sizeof(b));
        for(i=0;i<n;i++)scanf("%d",a+i);
        for(i=0;i<n;i++){
            t=a[i];
            if(t==1||b[t])continue;
            while(t!=1){
                if(t%2)t=(3*t+1)>>1;
                else t=t>>1;
                if(t<1002)b[t]=1;
            }
        }
        i--;t=0;
        while(i>=0){
            if(t && !b[a[i]])printf(" ");
            if(!b[a[i]]){printf("%d",a[i]);t=1;}
            i--;
        }
        if(t)printf("\n");
    }
    return 0;
}
{% endcodeblock %}

<h3>D题：寻找大富翁（hdoj3785）（九度1034）</h3>
<p>水题，注意不要进行排序，不然就可能会超时。</p>
{% codeblock lang:cpp Problem D %}
#include <stdio.h>
#include <memory.h>
int m,n,a[100002],b[10];
int main()
{
    int i,j,k;
    while(scanf("%d %d",&n,&m)){
        if(m==0&&n==0)break;
        for(i=0;i<n;i++)scanf("%d",a+i);
        memset(b,0,sizeof(b));
        for(i=0;i<n;i++){
            for(j=0;j<m;j++)
                if(a[i]>=b[j]){
                    for(k=m-1;k>j;k--)b[k]=b[k-1];
                    b[j]=a[i];
                    break;
                }
        }
        for(i=0;i<m-1;i++)
            printf("%d ",b[i]);
        printf("%d\n",b[i]);
    }
    return 0;
}
{% endcodeblock %}

<h3>E题：找出直系血亲（hdoj3786）（九度1035）</h3>
<p>水题，直接用DFS即可</p>
{% codeblock lang:cpp Problem E %}
#include <stdio.h>
#include <memory.h>
int m,n;
char tree[27];
int dfs(char a,char b){
    int dp;
    char t;
    dp=0;
    t=a;
    while(t){
        dp++;
        t=tree[t];
        if(t==b)return dp;
    }
    return 0;
}
int main()
{
    int i,d;
    char s[4];
    while(scanf("%d %d",&n,&m)){
        if(m==0&&n==0)break;
        memset(tree,0,sizeof(tree));
        for(i=0;i<n;i++){
            scanf("%s",s);
            if(s[1]!='-')tree[s[1]-64]=s[0]-64;
            if(s[2]!='-')tree[s[2]-64]=s[0]-64;
        }
        for(i=0;i<m;i++){
            scanf("%s",s);
            d=dfs(s[0]-64,s[1]-64);
            if(!d)d=-dfs(s[1]-64,s[0]-64);
            if(!d){printf("-\n");continue;}
            while(d>2||d<-2){
                printf("great-");
                if(d>0)d--;
                else d++;
            }
            switch(d){
                case 2:printf("grandparent\n");break;
                case 1:printf("parent\n");break;
                case -1:printf("child\n");break;
                case -2:printf("grandchild\n");break;
            }
        }
    }
    return 0;
}
{% endcodeblock %}

<p>小结：除了C题题目有点费解外，其他题都不难，可以说是既没考图论，又没有考DP。</p>

