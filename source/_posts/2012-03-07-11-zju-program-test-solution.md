---
layout: post
title: "11年浙大复试机试题解"
date: 2012-03-07 19:56
comments: true
categories: Program
tags: ZJU 机试 快排
---
<p>
11年浙大研究生复试机试题解
</p>

<h3>A题：A+B for Matrices （ 九度1001）</h3>
<p>水题</p>
{% codeblock lang:cpp Problem A %}
#include <stdio.h>
int m,n,a[10][10],b[10][10];
int main()
{
    int i,j,cnt;
    while(scanf("%d",&m)&&m>0){
        scanf("%d",&n);
        for(i=0;i<m;i++)
            for(j=0;j<n;j++)
                scanf("%d",a[i]+j);
        for(i=0;i<m;i++)
            for(j=0;j<n;j++){
                scanf("%d",b[i]+j);
                a[i][j]+=b[i][j];
            }
        cnt=0;
        for(i=0;i<m;i++){
            for(j=0;j<n;j++)
                if(a[i][j])break;
            if(j==n)cnt++;
        }
        for(i=0;i<n;i++){
            for(j=0;j<m;j++)
                if(a[j][i])break;
            if(j==m)cnt++;
        }
        printf("%d\n",cnt);
    }
    return 0;
}
{% endcodeblock %}

<!-- more -->
<h3>B题：Grading（ 九度 1002 ）</h3>
<p>继续水题！</p>
{% codeblock lang:cpp Problem B %}
#include <stdio.h>
int main()
{
    int p,t,g1,g2,g3,gj,t1,t2;
    while(scanf("%d %d %d %d %d %d",&p,&t,&g1,&g2,&g3,&gj)!=EOF){
        if(g1-g2<=t&&g2-g1<=t){printf("%.1f\n",(g1+g2)/2.0);continue;}
        t1=g3>g1 ? g3-g1 : g1-g3;
        t2=g3>g2 ? g3-g2 : g2-g3;
        if(t1>t&&t2>t){printf("%.1f\n",(float)gj);continue;}
        if(t1<=t&&t2<=t) {
            if(g1<g2)g1=g2;
            if(g1<g3)g1=g3;
            printf("%.1f\n",(float)g1);
            continue;
        }
        if(t1>t2)printf("%.1f\n",(g2+g3)/2.0);
        else printf("%.1f\n",(g1+g3)/2.0);
    }
    return 0;
}
{% endcodeblock %}

<h3>C题：Median（ 九度 1004）</h3>
<p>再继续水题！</p>

{% codeblock lang:cpp Problem C %}
#include <stdio.h>
long m,n,a[1000000],b[1000000];
int main()
{
    int i,j,k,t,mid;
    while(scanf("%d",&m)!=EOF){
        for(i=0;i<m;i++)scanf("%d",a+i);
        scanf("%d",&n);
        for(i=0;i<n;i++)scanf("%d",b+i);
        i=j=k=0;t=(m+n+1)/2;
        while(i<m&&j<n&&k<t){
            if(a[i]>b[j]){mid=b[j];j++;}
            else {mid=a[i];i++;}
            k++;
        }
        if(i==m&&k<t){
            while(k<t){j++;k++;}
            mid=b[j-1];
        }else if(j==n&&k<t){
            while(k<t){i++;k++;}
            mid=a[i-1];
        }
        printf("%d\n",mid);
    }
    return 0;
}
{% endcodeblock %}

<h3>D题：Graduate Admission（ 九度 1005）</h3>
<p>有点麻烦，要细心！</p>
{% codeblock lang:cpp Problem D %}
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
//m为学校数，n为学生数，k为学生填报的志愿数
//mq[i][0]为学校i计划招生数，mq[i][1]为学校实际招生数，
//mq[i][2] ~ mq[i][mq[i][1]+1]为招收的学生的学号
//ng[i][0]为学生学号，ng[i][1]为学生总成绩，ng[i][2]为学生面试成绩，
//ng[i][2]后面的k个数据是填报的志愿
int m,n,k,mq[100][1000],ng[40000][8];
int cmp1(const void*a,const void*b){
    int *t1,*t2;
    t1=(int*)a;t2=(int*)b;
    if(t1[1]!=t2[1])return t2[1]-t1[1];
    else return t1[2]-t2[2];  //总分相同时，面试成绩高的笔试成绩低
}
int cmp2(const void*a,const void*b){return *(int*)a-*(int*)b;}
int main()
{
    int i,j,t,p,q;
    //freopen("in.txt","r",stdin);
    //freopen("out.txt","w+",stdout);
    while(scanf("%d %d %d",&n,&m,&k)!=EOF){
        memset(mq,0,sizeof(mq));
        memset(ng,0,sizeof(ng));
        //输入部分
        for(i=0;i<m;i++)scanf("%d",mq+i);
        for(i=0;i<n;i++){
            ng[i][0]=i;
            for(j=1;j<k+3;j++)
                scanf("%d",ng[i]+j);
            ng[i][1]=ng[i][1]+ng[i][2];
        }
        //处理部分
        qsort(ng,n,sizeof(ng[0]),cmp1);  //将考生按分数排名
        //debug:输出排名
        //for(i=0;i<n;i++)printf("%2d:%2d %d %d %d\n",i,ng[i][0],ng[i][3],ng[i][4],ng[i][5]);
        for(i=0;i<n;i++){  //将考生按名次分配给各学校
            for(j=3;j<k+3;j++){ //从考生第一志愿开始选学校
                t=ng[i][j];  //排名为i的考生报考的第j-3个学校，学校编号为t
                if(mq[t][0]>0){
                    if(mq[t][0]>mq[t][1]){   //在学校招生名额范围内
                        mq[t][1]++;
                        mq[t][mq[t][1]+1]=ng[i][0];  //学校t招收学生ng[i][0]
                        break;
                    } else{   //招生名额范围外，排名相同的考生
                        p=mq[t][mq[t][1]+1];  //p为已招收的最后一个考生的学号
                        for(q=0;q<i;q++)   //查找学号为p的考生排名后的位置k
                            if(ng[q][0]==p){p=q;break;}
                            if(ng[p][1]==ng[i][1]&&ng[p][2]==ng[i][2]){  //判断排名是否相同
                            mq[t][1]++;
                            mq[t][mq[t][1]+1]=ng[i][0];   //录取排名相同的考生
                            break;
                        }
                    }
                }
            }
        }
        //输出部分
        for(i=0;i<m;i++){ //分配给每个学校的学生，先按学号排序，再输出
            qsort(mq[i]+2,mq[i][1],sizeof(mq[i][2]),cmp2);
            if(mq[i][1]>0)printf("%d",mq[i][2]);
            for(j=3;j<mq[i][1]+2;j++)printf(" %d",mq[i][j]);
            printf("\n");
        }
    }
    return 0;
}
{% endcodeblock %}

<p>总体来说，这套题比较简单！</p>

