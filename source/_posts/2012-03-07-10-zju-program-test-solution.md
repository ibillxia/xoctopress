---
layout: post
title: "10年浙大复试机试题解"
date: 2012-03-07 12:08
comments: true
categories: Program
tags: ZJU 机试 快排 并查集
---
<p>
10年浙大研究生复试机试题解
</p>

<h3>A题：A+B（hdoj3787）（九度1003）</h3>
<p>水题，不解释，直接上代码：</p>
{% codeblock lang:cpp Problem A %}
#include <stdio.h>
long a,b;
int main()
{
    int i,f;
    char s[30];
    while(scanf("%s",s)!=EOF){
        a=b=0;
        if(s[0]=='-'){f=-1;i=1;}
        else {f=1;i=0;}
        while(s[i]){
            if(s[i]!=',')a=a*10+s[i]-'0';
            i++;
        }
        a=a*f;
        getchar();
        scanf("%s",s);
        if(s[0]=='-'){f=-1;i=1;}
        else {f=1;i=0;}
        while(s[i]){
            if(s[i]!=',')b=b*10+s[i]-'0';
            i++;
        }
        b=b*f;
        printf("%d\n",a+b);
    }
    return 0;
}
{% endcodeblock %}

<!-- more -->
<h3>B题：ZOJ问题（hdoj3788）（九度1006）</h3>
<p>题目不是很好懂，要仔细阅读，根据题目的三个条件找规律，
最后发现Accepted的字符串应满足如下条件：</br>
设a为第一个z前o的个数，b为z和j之间o的个数，c为j之后o的个数，
则有c=a*b，其中b>0.代码如下：
</p>
{% codeblock lang:cpp Problem B %}
#include <stdio.h>
#include <string.h>
char s[1001];
int main()
{
    int a,b,c;
    char *p;
    while(scanf("%s",s)!=EOF){
        if(!strcmp(s,"zoj")){printf("Accepted\n");continue;}
        a=b=c=0;
        p=s;
        while(*p=='o'){a++;p++;}
        if(*p=='z'){
            p++;
            while(*p=='o'){b++;p++;}
            if(*p=='j'){
                p++;
                while(*p=='o'){c++;p++;}
                if(!(*p) && b>0 && c==a*b){printf("Accepted\n");continue;}
            }
        }
        printf("Wrong Answer\n");
    }
    return 0;
}
{% endcodeblock %}

<h3>C题：奥运排序问题（hdoj3789）（九度1007）</h3>
<p>排序问题，题目不难，但要把题目理解正确、做正确却不是那么容易。
注意（1）只需要给M个（而不是N个）国家排序；
（2）最后输出结果要按输入的顺序给出（hdoj，但在九度上是要按照国家的编号小到大顺序输出）。
hdoj AC的代码如下：</p>

{% codeblock lang:cpp Problem C %}
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<algorithm>
using namespace std;


const int INF=10005;
struct node{
    float gold,medal,gm,mm,man;
    int no,fs,pm,bc;
}a[10005],b[10005]; //fs表示排序方式，bc表示本次排名，pm表示最终排名

int com1(node a,node b){return a.gold>b.gold;}
int com2(node a,node b){return a.medal>b.medal;}
int com3(node a,node b){return a.gm>b.gm;}
int com4(node a,node b){return a.mm>b.mm;}
int com5(node a,node b){return a.no<b.no;}


int main()
{
    int i,t,m,n;
    //freopen("in.txt","r",stdin);
    //freopen("out2.txt","w+",stdout);
    while(scanf("%d%d",&n,&m)!=EOF){
        for(i=1;i<=n;i++){
            scanf("%f%f%f",&a[i].gold,&a[i].medal,&a[i].man);
            a[i].gm=a[i].gold/a[i].man;
            a[i].mm=a[i].medal/a[i].man;
            a[i].no=i;a[i].pm=INF;
        }
        for(i=1;i<=m;i++){//选出要排序的m个数给b
            scanf("%d",&t);
            b[i]=a[t+1];
            b[i].no=i;
        }
        sort(b+1,b+m+1,com1);//按gold排序
        b[0].bc=1;b[0].gold=b[0].medal=b[0].gm=b[0].mm=-1;
        for(i=1;i<=m;i++){
            if(b[i].gold==b[i-1].gold){b[i].bc=b[i-1].bc;} //处理相同名次的
            else b[i].bc=i;
            if(b[i].pm>b[i].bc){b[i].pm=b[i].bc;b[i].fs=1;}
        }
        sort(b+1,b+m+1,com2);//按medal排序
        for(i=1;i<=m;i++){
            if(b[i].medal==b[i-1].medal){b[i].bc=b[i-1].bc;}
            else b[i].bc=i;
            if(b[i].pm>b[i].bc){b[i].pm=b[i].bc;b[i].fs=2;}
        }
        sort(b+1,b+m+1,com3);//按gm排序
        for(i=1;i<=m;i++){
            if(b[i].gm==b[i-1].gm){b[i].bc=b[i-1].bc;}
            else b[i].bc=i;
            if(b[i].pm>b[i].bc){b[i].pm=b[i].bc;b[i].fs=3;}
        }
        sort(b+1,b+m+1,com4);//按mm排序
        for(i=1;i<=m;i++){
            if(b[i].mm==b[i-1].mm){b[i].bc=b[i-1].bc;}
            else b[i].bc=i;
            if(b[i].pm>b[i].bc){b[i].pm=b[i].bc;b[i].fs=4;}
        }
        sort(b+1,b+m+1,com5);//按no排序
        for(i=1;i<=m;i++)
            printf("%d:%d\n",b[i].pm,b[i].fs);
        printf("\n");
    }
    return 0;
}
{% endcodeblock %}

<h3>D题：最短路径问题（hdoj3790）（九度1008）</h3>
<p>双重最短路问题，用dijkstra算法（模板题）。代码如下：</p>
{% codeblock lang:cpp Problem D %}
#include <stdio.h>
#include <memory.h>
#define INF 0x1fffffff
#define N 1000
int m,n,s,t,g[N][N][2],lp[N],lc[N],v[N];
void dijkstra(){
    int i,j,k,md,mp;
    memset(v,0,sizeof(v));
    memset(lp,0,sizeof(lp));
    memset(lc,0,sizeof(lc));
    for(i=0;i<n;i++)lp[i]=g[s][i][0];
    for(i=0;i<n;i++)lc[i]=g[s][i][1];
    v[s]=1;
    for(i=0;i<n;i++){
        k=-1;md=INF;mp=INF;
        for(j=0;j<n;j++)
            if(!v[j]){
                if(lp[j]<md){k=j;md=lp[j];mp=lc[j];}
                else if(lp[j]==md&&lc[j]<mp){k=j;mp=lc[j];}
            }
        if(k==t)return;
        v[k]=1;
        for(j=0;j<n;j++)
            if(lp[j]>lp[k]+g[k][j][0]){
                lp[j]=lp[k]+g[k][j][0];
                lc[j]=lc[k]+g[k][j][1];
            }else if(lp[j]==lp[k]+g[k][j][0]&&lc[j]>lc[k]+g[j][k][1]){
                lp[j]=lp[k]+g[k][j][0];
                lc[j]=lc[k]+g[k][j][1];
            }
    }
}
int main()
{
    int i,j,a,b,d,p;
    while(scanf("%d %d",&n,&m)!=EOF){
        if(m==0&&n==0)break;
        for(i=0;i<n;i++)
            for(j=0;j<n;j++)
                g[i][j][0]=g[i][j][1]=INF;


        for(i=0;i<m;i++){
            scanf("%d %d %d %d",&a,&b,&d,&p);
            a--;b--;
            if(g[a][b][0]>d){
                g[a][b][0]=g[b][a][0]=d;
                g[a][b][1]=g[b][a][1]=p;
            }
        }
        scanf("%d %d",&s,&t);
        s--;t--;
        dijkstra();
        printf("%d %d\n",lp[t],lc[t]);
    }
    return 0;
}
{% endcodeblock %}

<h3>E题：二叉搜索树（hdoj3791）（九度1009）</h3>
<p>题目给的数据的范围很小，一开始就考虑用数组来存储树，提交后RE了。
没办法，改用指针实现，果断AC了，代码如下：</p>
{% codeblock lang:cpp Problem E %}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct node{
    int data;
    struct node *lchild,*rchild;
}btnode,*btree;
int n;
btree ta,tb;
void creat(char s[],btree *t){
    int i,k;
    btree p,q;
    if(s[0]=='\0'){t=NULL;return;}
    *t=(btree)malloc(sizeof(btnode));
    (*t)->data=s[0]-'0';
    (*t)->lchild=(*t)->rchild=NULL;
    i=1;
    while(s[i]){
        k=s[i]-'0';
        p=*t;
        while(p){
            q=p;
            if(k<p->data) p=p->lchild;
            else p=p->rchild;
        }
        p=(btree)malloc(sizeof(btnode));
        p->data=k;
        p->lchild=p->rchild=NULL;
        if(k<q->data)q->lchild=p;
        else q->rchild=p;
        i++;
    }
}
int cmp(btree ta,btree tb){
    btree p,q;
    p=ta;q=tb;
    if((p&&!q)||(q&&!p)||(p&&q&&p->data!=q->data))return 0;
    if(p&&q&&p->data==q->data)
        if(!cmp(p->lchild,q->lchild)||!cmp(p->rchild,q->rchild))
            return 0;
    return 1;
}
int main()
{
    char str[12];
    int i,la,lb;
    while(scanf("%d",&n)&&n!=0){
        scanf("%s",str);
        la=strlen(str);
        creat(str,&ta);
        for(i=0;i<n;i++){
            scanf("%s",str);
            lb=strlen(str);
            if(lb!=la){printf("NO\n");continue;}
            creat(str,&tb);
            if(cmp(ta,tb))printf("YES\n");
            else printf("NO\n");
        }
    }
    return 0;
}
{% endcodeblock %}

<p>小结：个人感觉，整套题目是这几年来最难得，只因为B题难读懂，C题题意容易误读，
D题的双重最短路初次做，表示不会，E题的测试数据又不按题目要求给，很坑爹啊！
如果不幸在10年考的话，估计结局会很悲剧了。</p>

