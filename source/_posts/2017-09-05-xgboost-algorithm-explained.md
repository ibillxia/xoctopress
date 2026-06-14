---   
layout: post   
title: "XGBoost算法原理详解"   
date: 2017-09-05 21:38   
comments: true   
categories: DataScience   
tags: 机器学习 XGBoost 梯度提升   
---   

文章内容可能会相对比较多，读者可以点击上方目录，直接阅读自己感兴趣的章节。

# 1.序

关于xgboost的原理网络上的资源很少，大多数还停留在应用层面，本文通过学习陈天奇博士的PPT、论文、一些网络资源，希望对xgboost原理进行深入理解。（笔者在最后的参考文献中会给出地址）

# 2.xgboost vs gbdt

说到xgboost，不得不说gbdt，两者都是boosting方法（如图1所示），了解gbdt可以看我这篇文章 地址。

<center>{% img /images/2017/IMAG2017090501.png %}</center>
<center>图1</center>
<!--more-->
<br>
如果不考虑工程实现、解决问题上的一些差异，xgboost与gbdt比较大的不同就是目标函数的定义。

<center>{% img /images/2017/IMAG2017090502.png %}</center>
<br>
注：红色箭头指向的l即为损失函数；红色方框为正则项，包括L1、L2；红色圆圈为常数项。xgboost利用泰勒展开三项，做一个近似，我们可以很清晰地看到，最终的目标函数只依赖于每个数据点的在误差函数上的一阶导数和二阶导数。

# 3.原理

对于上面给出的目标函数，我们可以进一步化简

（1）定义树的复杂度

对于f的定义做一下细化，把树拆分成结构部分q和叶子权重部分w。下图是一个具体的例子。结构函数q把输入映射到叶子的索引号上面去，而w给定了每个索引号对应的叶子分数是什么。

<center>{% img /images/2017/IMAG2017090503.png %}</center>
<br>
定义这个复杂度包含了一棵树里面节点的个数，以及每个树叶子节点上面输出分数的L2模平方。当然这不是唯一的一种定义方式，不过这一定义方式学习出的树效果一般都比较不错。下图还给出了复杂度计算的一个例子。

<center>{% img /images/2017/IMAG2017090504.png %}</center>
<br>
注：方框部分在最终的模型公式中控制这部分的比重,对应模型参数中的lambda ，gamma

在这种新的定义下，我们可以把目标函数进行如下改写，其中I被定义为每个叶子上面样本集合

<center>{% img /images/2017/IMAG2017090505.gif %}</center>
<br>
g是一阶导数，h是二阶导数

<center>{% img /images/2017/IMAG2017090506.png %}</center>
<br>
这一个目标包含了T个相互独立的单变量二次函数。我们可以定义

<center>{% img /images/2017/IMAG2017090507.png %}</center>
<br>
最终公式可以化简为

<center>{% img /images/2017/IMAG2017090508.png %}</center>
<br>
通过对求导等于0，可以得到

<center>{% img /images/2017/IMAG2017090509.png %}</center>
<br>
然后把最优解代入得到：

<center>{% img /images/2017/IMAG2017090510.png %}</center>
<br>
（2）打分函数计算示例

Obj代表了当我们指定一个树的结构的时候，我们在目标上面最多减少多少。我们可以把它叫做结构分数(structure score)

<center>{% img /images/2017/IMAG2017090511.png %}</center>
<br>
（3）分裂节点

论文中给出了两种分裂节点的方法

（1）贪心法：

每一次尝试去对已有的叶子加入一个分割

<center>{% img /images/2017/IMAG2017090512.png %}</center>
<br>
对于每次扩展，我们还是要枚举所有可能的分割方案，如何高效地枚举所有的分割呢？我假设我们要枚举所有x < a 这样的条件，对于某个特定的分割a我们要计算a左边和右边的导数和。

<center>{% img /images/2017/IMAG2017090513.png %}</center>
<br>
我们可以发现对于所有的a，我们只要做一遍从左到右的扫描就可以枚举出所有分割的梯度和GL和GR。然后用上面的公式计算每个分割方案的分数就可以了。

观察这个目标函数，大家会发现第二个值得注意的事情就是引入分割不一定会使得情况变好，因为我们有一个引入新叶子的惩罚项。优化这个目标对应了树的剪枝， 当引入的分割带来的增益小于一个阀值的时候，我们可以剪掉这个分割。大家可以发现，当我们正式地推导目标的时候，像计算分数和剪枝这样的策略都会自然地出现，而不再是一种因为heuristic（启发式）而进行的操作了。

下面是论文中的算法

<center>{% img /images/2017/IMAG2017090514.png %}</center>
<br>
（2）近似算法：

主要针对数据太大，不能直接进行计算

<center>{% img /images/2017/IMAG2017090515.png %}</center>
<br>
# 4.自定义损失函数（指定grad、hess）

（1）损失函数

<center>{% img /images/2017/IMAG2017090516.png %}</center>
<br>
（2）grad、hess推导

<center>{% img /images/2017/IMAG2017090517.png %}</center>
<br>
（3）官方代码

```python
#!/usr/bin/python
import numpy as np
import xgboost as xgb
###
# advanced: customized loss function
#
print ('start running example to used customized objective function')

dtrain = xgb.DMatrix('../data/agaricus.txt.train')
dtest = xgb.DMatrix('../data/agaricus.txt.test')

# note: for customized objective function, we leave objective as default
# note: what we are getting is margin value in prediction
# you must know what you are doing
param = {'max_depth': 2, 'eta': 1, 'silent': 1}
watchlist = [(dtest, 'eval'), (dtrain, 'train')]
num_round = 2

# user define objective function, given prediction, return gradient and second order gradient
# this is log likelihood loss
def logregobj(preds, dtrain):
    labels = dtrain.get_label()
    preds = 1.0 / (1.0 + np.exp(-preds))
    grad = preds - labels
    hess = preds * (1.0-preds)
    return grad, hess

# user defined evaluation function, return a pair metric_name, result
# NOTE: when you do customized loss function, the default prediction value is margin
# this may make builtin evaluation metric not function properly
# for example, we are doing logistic loss, the prediction is score before logistic transformation
# the builtin evaluation error assumes input is after logistic transformation
# Take this in mind when you use the customization, and maybe you need write customized evaluation function
def evalerror(preds, dtrain):
    labels = dtrain.get_label()
    # return a pair metric_name, result
    # since preds are margin(before logistic transformation, cutoff at 0)
    return 'error', float(sum(labels != (preds > 0.0))) / len(labels)

# training with customized objective, we can also do step by step training
# simply look at xgboost.py's implementation of train
bst = xgb.train(param, dtrain, num_round, watchlist, logregobj, evalerror)

```

# 5.Xgboost调参

由于xgboost的参数过多，这里介绍三种思路

（1）GridSearch

（2）Hyperopt

# 6.工程实现优化

（1）Column Blocks and Parallelization

<center>{% img /images/2017/IMAG2017090518.png %}</center>
<br>
（2）Cache Aware Access

- A thread pre-fetches data from non-continuous memory into a continuous buffer.

- The main thread accumulates gradients statistics in the continuous buffer.

（3）System Tricks

- Block pre-fetching.

- Utilize multiple disks to parallelize disk operations.

- LZ4 compression(popular recent years for outstanding performance).

- Unrolling loops.

- OpenMP

# 7.代码走读

这块非常感谢杨军老师的无私奉献【4】

个人看代码用的是SourceInsight，由于xgboost有些文件是cc后缀名，可以通过以下命令修改下（默认的识别不了）

```
find ./-name"*.cc"| awk -F"."'{print $2}'| xargs -i-t mv ./{}.cc  ./{}.cpp
```

实际上，对XGBoost的源码进行走读分析之后，能够看到下面的主流程：

```
cli_main.cc:
main()
     -> CLIRunTask()
          -> CLITrain()
               -> DMatrix::Load()
               -> learner = Learner::Create()
               -> learner->Configure()
               -> learner->InitModel()
               -> for (i = 0; i < param.num_round; ++i)
                    -> learner->UpdateOneIter()
                    -> learner->Save()    
learner.cc:
Create()
      -> new LearnerImpl()
Configure()
InitModel()
     -> LazyInitModel()
          -> obj_ = ObjFunction::Create()
               -> objective.cc
                    Create()
                         -> SoftmaxMultiClassObj(multiclass_obj.cc)/
                              LambdaRankObj(rank_obj.cc)/
                              RegLossObj(regression_obj.cc)/
                              PoissonRegression(regression_obj.cc)
          -> gbm_ = GradientBooster::Create()
               -> gbm.cc
                    Create()
                         -> GBTree(gbtree.cc)/
                              GBLinear(gblinear.cc)
          -> obj_->Configure()
          -> gbm_->Configure()
UpdateOneIter()
      -> PredictRaw()
      -> obj_->GetGradient()
      -> gbm_->DoBoost()         

gbtree.cc:
Configure()
      -> for (up in updaters)
           -> up->Init()
DoBoost()
      -> BoostNewTrees()
           -> new_tree = new RegTree()
           -> for (up in updaters)
                -> up->Update(new_tree)    

tree_updater.cc:
Create()
     -> ColMaker/DistColMaker(updater_colmaker.cc)/
        SketchMaker(updater_skmaker.cc)/
        TreeRefresher(updater_refresh.cc)/
        TreePruner(updater_prune.cc)/
        HistMaker/CQHistMaker/
                  GlobalProposalHistMaker/
                  QuantileHistMaker(updater_histmaker.cc)/
        TreeSyncher(updater_sync.cc)
```

从上面的代码主流程可以看到，在XGBoost的实现中，对算法进行了模块化的拆解，几个重要的部分分别是：

I. ObjFunction：对应于不同的Loss Function，可以完成一阶和二阶导数的计算。

II. GradientBooster：用于管理Boost方法生成的Model，注意，这里的Booster Model既可以对应于线性Booster Model，也可以对应于Tree Booster Model。

III. Updater：用于建树，根据具体的建树策略不同，也会有多种Updater。比如，在XGBoost里为了性能优化，既提供了单机多线程并行加速，也支持多机分布式加速。也就提供了若干种不同的并行建树的updater实现，按并行策略的不同，包括：

I). inter-feature exact parallelism （特征级精确并行）

II). inter-feature approximate parallelism（特征级近似并行，基于特征分bin计算，减少了枚举所有特征分裂点的开销）

III). intra-feature parallelism （特征内并行）

此外，为了避免overfit，还提供了一个用于对树进行剪枝的updater(TreePruner)，以及一个用于在分布式场景下完成结点模型参数信息通信的updater(TreeSyncher)，这样设计，关于建树的主要操作都可以通过Updater链的方式串接起来，比较一致干净，算是Decorator设计模式[4]的一种应用。

XGBoost的实现中，最重要的就是建树环节，而建树对应的代码中，最主要的也是Updater的实现。所以我们会以Updater的实现作为介绍的入手点。

以ColMaker（单机版的inter-feature parallelism，实现了精确建树的策略）为例，其建树操作大致如下：

```
updater_colmaker.cc:
ColMaker::Update()
     -> Builder builder;
     -> builder.Update()
          -> InitData()
          -> InitNewNode() // 为可用于split的树结点（即叶子结点，初始情况下只有一个
                           // 叶结点，也就是根结点) 计算统计量，包括gain/weight等
          ->  for (depth = 0; depth < 树的最大深度; ++depth)
               -> FindSplit()
                    -> for (each feature) // 通过OpenMP获取
                                          // inter-feature parallelism
                         -> UpdateSolution()      
                              -> EnumerateSplit()  // 每个执行线程处理一个特征，
                                                   // 选出每个特征的
                                                   // 最优split point
                              -> ParallelFindSplit()   
                                   // 多个执行线程同时处理一个特征，选出该特征
                                   //的最优split point; 
                                   // 在每个线程里汇总各个线程内分配到的数据样
                                   //本的统计量(grad/hess);
                                   // aggregate所有线程的样本统计(grad/hess)，       
                                   //计算出每个线程分配到的样本集合的边界特征值作为
                                   //split point的最优分割点;
                                   // 在每个线程分配到的样本集合对应的特征值集合进
                                   //行枚举作为split point，选出最优分割点
                         -> SyncBestSolution()  
                               // 上面的UpdateSolution()/ParallelFindSplit()
                               //会为所有待扩展分割的叶结点找到特征维度的最优split 
                               //point，比如对于叶结点A，OpenMP线程1会找到特征F1 
                               //的最优split point，OpenMP线程2会找到特征F2的最
                               //优split point，所以需要进行全局sync，找到叶结点A
                               //的最优split point。
                         -> 为需要进行分割的叶结点创建孩子结点     
               -> ResetPosition() 
                      //根据上一步的分割动作，更新样本到树结点的映射关系
                      // Missing Value(i.e. default)和非Missing Value(i.e. 
                      //non-default)分别处理
               -> UpdateQueueExpand() 
                      // 将待扩展分割的叶子结点用于替换qexpand_，作为下一轮split的
                      //起始基础
               -> InitNewNode()  // 为可用于split的树结点计算统计量
```

# 8.python、R对于xgboost的简单使用

任务：二分类，存在样本不均衡问题（scale_pos_weight可以一定程度上解读此问题）

【python】

<center>{% img /images/2017/IMAG2017090519.png %}</center>
<br>
【R】

<center>{% img /images/2017/IMAG2017090520.png %}</center>
<br>
# 9.xgboost中比较重要的参数介绍

（1）objective [ default=reg:linear ] 定义学习任务及相应的学习目标，可选的目标函数如下：

- “reg:linear” –线性回归。

- “reg:logistic” –逻辑回归。

- “binary:logistic” –二分类的逻辑回归问题，输出为概率。

- “binary:logitraw” –二分类的逻辑回归问题，输出的结果为wTx。

- “count:poisson” –计数问题的poisson回归，输出结果为poisson分布。 在poisson回归中，max_delta_step的缺省值为0.7。(used to safeguard optimization)

- “multi:softmax” –让XGBoost采用softmax目标函数处理多分类问题，同时需要设置参数num_class（类别个数）

- “multi:softprob” –和softmax一样，但是输出的是ndata * nclass的向量，可以将该向量reshape成ndata行nclass列的矩阵。没行数据表示样本所属于每个类别的概率。

- “rank:pairwise” –set XGBoost to do ranking task by minimizing the pairwise loss

（2）’eval_metric’ The choices are listed below，评估指标:

- “rmse”: root mean square error

- “logloss”: negative log-likelihood

- “error”: Binary classification error rate. It is calculated as #(wrong cases)/#(all cases). For the predictions, the evaluation will regard the instances with prediction value larger than 0.5 as positive instances, and the others as negative instances.

- “merror”: Multiclass classification error rate. It is calculated as #(wrong cases)/#(all cases).

- “mlogloss”: Multiclass logloss

- “auc”: Area under the curve for ranking evaluation.

- “ndcg”:Normalized Discounted Cumulative Gain

- “map”:Mean average precision

- “ndcg@n”,”map@n”: n can be assigned as an integer to cut off the top positions in the lists for evaluation.

- “ndcg-“,”map-“,”ndcg@n-“,”map@n-“: In XGBoost, NDCG and MAP will evaluate the score of a list without any positive samples as 1. By adding “-” in the evaluation metric XGBoost will evaluate these score as 0 to be consistent under some conditions.

（3）lambda [default=0] L2 正则的惩罚系数

（4）alpha [default=0] L1 正则的惩罚系数

（5）lambda_bias 在偏置上的L2正则。缺省值为0（在L1上没有偏置项的正则，因为L1时偏置不重要）

（6）eta [default=0.3]

为了防止过拟合，更新过程中用到的收缩步长。在每次提升计算之后，算法会直接获得新特征的权重。 eta通过缩减特征的权重使提升计算过程更加保守。缺省值为0.3

取值范围为：[0,1]

（7）max_depth [default=6] 数的最大深度。缺省值为6 ，取值范围为：[1,∞]

（8）min_child_weight [default=1]

孩子节点中最小的样本权重和。如果一个叶子节点的样本权重和小于min_child_weight则拆分过程结束。在现行回归模型中，这个参数是指建立每个模型所需要的最小样本数。该成熟越大算法越conservative

取值范围为: [0,∞]

# 10.DART

核心思想就是将dropout引入XGBoost

示例代码

```python
import xgboost as xgb
# read in data
dtrain = xgb.DMatrix('demo/data/agaricus.txt.train?format=libsvm')
dtest = xgb.DMatrix('demo/data/agaricus.txt.test?format=libsvm')
# specify parameters via map
param = {'max_depth': 5, 'learning_rate': 0.1,
         'objective': 'binary:logistic',
         'sample_type': 'uniform',
         'normalize_type': 'tree',
         'rate_drop': 0.1,
         'skip_drop': 0.5}
num_round = 50
bst = xgb.train(param, dtrain, num_round)
preds = bst.predict(dtest)
```


更多细节可以阅读参考文献5

# 11.csr_matrix训练XGBoost

当数据规模比较大、较多列比较稀疏时，可以使用csr_matrix训练XGBoost模型，从而节约内存。

下面是Kaggle比赛中TalkingData开源的代码，可以学习一下，详见参考文献6。

```python
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import os
from sklearn.preprocessing import LabelEncoder
from scipy.sparse import csr_matrix, hstack
import xgboost as xgb
from sklearn.cross_validation import StratifiedKFold
from sklearn.metrics import log_loss

datadir = '../input'
gatrain = pd.read_csv(os.path.join(datadir,'gender_age_train.csv'),
                      index_col='device_id')
gatest = pd.read_csv(os.path.join(datadir,'gender_age_test.csv'),
                     index_col = 'device_id')
phone = pd.read_csv(os.path.join(datadir,'phone_brand_device_model.csv'))
# Get rid of duplicate device ids in phone
phone = phone.drop_duplicates('device_id',keep='first').set_index('device_id')
events = pd.read_csv(os.path.join(datadir,'events.csv'),
                     parse_dates=['timestamp'], index_col='event_id')
appevents = pd.read_csv(os.path.join(datadir,'app_events.csv'), 
                        usecols=['event_id','app_id','is_active'],
                        dtype={'is_active':bool})
applabels = pd.read_csv(os.path.join(datadir,'app_labels.csv'))

gatrain['trainrow'] = np.arange(gatrain.shape[0])
gatest['testrow'] = np.arange(gatest.shape[0])

brandencoder = LabelEncoder().fit(phone.phone_brand)
phone['brand'] = brandencoder.transform(phone['phone_brand'])
gatrain['brand'] = phone['brand']
gatest['brand'] = phone['brand']
Xtr_brand = csr_matrix((np.ones(gatrain.shape[0]), 
                       (gatrain.trainrow, gatrain.brand)))
Xte_brand = csr_matrix((np.ones(gatest.shape[0]), 
                       (gatest.testrow, gatest.brand)))
print('Brand features: train shape {}, test shape {}'.format(Xtr_brand.shape, Xte_brand.shape))

m = phone.phone_brand.str.cat(phone.device_model)
modelencoder = LabelEncoder().fit(m)
phone['model'] = modelencoder.transform(m)
gatrain['model'] = phone['model']
gatest['model'] = phone['model']
Xtr_model = csr_matrix((np.ones(gatrain.shape[0]), 
                       (gatrain.trainrow, gatrain.model)))
Xte_model = csr_matrix((np.ones(gatest.shape[0]), 
                       (gatest.testrow, gatest.model)))
print('Model features: train shape {}, test shape {}'.format(Xtr_model.shape, Xte_model.shape))

appencoder = LabelEncoder().fit(appevents.app_id)
appevents['app'] = appencoder.transform(appevents.app_id)
napps = len(appencoder.classes_)
deviceapps = (appevents.merge(events[['device_id']], how='left',left_on='event_id',right_index=True)
                       .groupby(['device_id','app'])['app'].agg(['size'])
                       .merge(gatrain[['trainrow']], how='left', left_index=True, right_index=True)
                       .merge(gatest[['testrow']], how='left', left_index=True, right_index=True)
                       .reset_index())

d = deviceapps.dropna(subset=['trainrow'])
Xtr_app = csr_matrix((np.ones(d.shape[0]), (d.trainrow, d.app)), 
                      shape=(gatrain.shape[0],napps))
d = deviceapps.dropna(subset=['testrow'])
Xte_app = csr_matrix((np.ones(d.shape[0]), (d.testrow, d.app)), 
                      shape=(gatest.shape[0],napps))
print('Apps data: train shape {}, test shape {}'.format(Xtr_app.shape, Xte_app.shape))

applabels = applabels.loc[applabels.app_id.isin(appevents.app_id.unique())]
applabels['app'] = appencoder.transform(applabels.app_id)
labelencoder = LabelEncoder().fit(applabels.label_id)
applabels['label'] = labelencoder.transform(applabels.label_id)
nlabels = len(labelencoder.classes_)

devicelabels = (deviceapps[['device_id','app']]
                .merge(applabels[['app','label']])
                .groupby(['device_id','label'])['app'].agg(['size'])
                .merge(gatrain[['trainrow']], how='left', left_index=True, right_index=True)
                .merge(gatest[['testrow']], how='left', left_index=True, right_index=True)
                .reset_index())
devicelabels.head()

d = devicelabels.dropna(subset=['trainrow'])
Xtr_label = csr_matrix((np.ones(d.shape[0]), (d.trainrow, d.label)), 
                      shape=(gatrain.shape[0],nlabels))
d = devicelabels.dropna(subset=['testrow'])
Xte_label = csr_matrix((np.ones(d.shape[0]), (d.testrow, d.label)), 
                      shape=(gatest.shape[0],nlabels))
print('Labels data: train shape {}, test shape {}'.format(Xtr_label.shape, Xte_label.shape))

Xtrain = hstack((Xtr_brand, Xtr_model, Xtr_app, Xtr_label), format='csr')
Xtest =  hstack((Xte_brand, Xte_model, Xte_app, Xte_label), format='csr')
print('All features: train shape {}, test shape {}'.format(Xtrain.shape, Xtest.shape))

targetencoder = LabelEncoder().fit(gatrain.group)
y = targetencoder.transform(gatrain.group)

########## XGBOOST ##########

params = {}
params['booster'] = 'gblinear'
params['objective'] = "multi:softprob"
params['eval_metric'] = 'mlogloss'
params['eta'] = 0.005
params['num_class'] = 12
params['lambda'] = 3
params['alpha'] = 2

# Random 10% for validation
kf = list(StratifiedKFold(y, n_folds=10, shuffle=True, random_state=4242))[0]

Xtr, Xte = Xtrain[kf[0], :], Xtrain[kf[1], :]
ytr, yte = y[kf[0]], y[kf[1]]

print('Training set: ' + str(Xtr.shape))
print('Validation set: ' + str(Xte.shape))

d_train = xgb.DMatrix(Xtr, label=ytr)
d_valid = xgb.DMatrix(Xte, label=yte)

watchlist = [(d_train, 'train'), (d_valid, 'eval')]

clf = xgb.train(params, d_train, 1000, watchlist, early_stopping_rounds=25)

pred = clf.predict(xgb.DMatrix(Xtest))

pred = pd.DataFrame(pred, index = gatest.index, columns=targetencoder.classes_)
pred.head()
pred.to_csv('sparse_xgb.csv', index=True)

#params['lambda'] = 1
#for alpha in [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]:
#    params['alpha'] = alpha
#    clf = xgb.train(params, d_train, 1000, watchlist, early_stopping_rounds=25)
#    print('^' + str(alpha))import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import os
from sklearn.preprocessing import LabelEncoder
from scipy.sparse import csr_matrix, hstack
import xgboost as xgb
from sklearn.cross_validation import StratifiedKFold
from sklearn.metrics import log_loss

datadir = '../input'
gatrain = pd.read_csv(os.path.join(datadir,'gender_age_train.csv'),
                      index_col='device_id')
gatest = pd.read_csv(os.path.join(datadir,'gender_age_test.csv'),
                     index_col = 'device_id')
phone = pd.read_csv(os.path.join(datadir,'phone_brand_device_model.csv'))
# Get rid of duplicate device ids in phone
phone = phone.drop_duplicates('device_id',keep='first').set_index('device_id')
events = pd.read_csv(os.path.join(datadir,'events.csv'),
                     parse_dates=['timestamp'], index_col='event_id')
appevents = pd.read_csv(os.path.join(datadir,'app_events.csv'), 
                        usecols=['event_id','app_id','is_active'],
                        dtype={'is_active':bool})
applabels = pd.read_csv(os.path.join(datadir,'app_labels.csv'))

gatrain['trainrow'] = np.arange(gatrain.shape[0])
gatest['testrow'] = np.arange(gatest.shape[0])

brandencoder = LabelEncoder().fit(phone.phone_brand)
phone['brand'] = brandencoder.transform(phone['phone_brand'])
gatrain['brand'] = phone['brand']
gatest['brand'] = phone['brand']
Xtr_brand = csr_matrix((np.ones(gatrain.shape[0]), 
                       (gatrain.trainrow, gatrain.brand)))
Xte_brand = csr_matrix((np.ones(gatest.shape[0]), 
                       (gatest.testrow, gatest.brand)))
print('Brand features: train shape {}, test shape {}'.format(Xtr_brand.shape, Xte_brand.shape))

m = phone.phone_brand.str.cat(phone.device_model)
modelencoder = LabelEncoder().fit(m)
phone['model'] = modelencoder.transform(m)
gatrain['model'] = phone['model']
gatest['model'] = phone['model']
Xtr_model = csr_matrix((np.ones(gatrain.shape[0]), 
                       (gatrain.trainrow, gatrain.model)))
Xte_model = csr_matrix((np.ones(gatest.shape[0]), 
                       (gatest.testrow, gatest.model)))
print('Model features: train shape {}, test shape {}'.format(Xtr_model.shape, Xte_model.shape))

appencoder = LabelEncoder().fit(appevents.app_id)
appevents['app'] = appencoder.transform(appevents.app_id)
napps = len(appencoder.classes_)
deviceapps = (appevents.merge(events[['device_id']], how='left',left_on='event_id',right_index=True)
                       .groupby(['device_id','app'])['app'].agg(['size'])
                       .merge(gatrain[['trainrow']], how='left', left_index=True, right_index=True)
                       .merge(gatest[['testrow']], how='left', left_index=True, right_index=True)
                       .reset_index())

d = deviceapps.dropna(subset=['trainrow'])
Xtr_app = csr_matrix((np.ones(d.shape[0]), (d.trainrow, d.app)), 
                      shape=(gatrain.shape[0],napps))
d = deviceapps.dropna(subset=['testrow'])
Xte_app = csr_matrix((np.ones(d.shape[0]), (d.testrow, d.app)), 
                      shape=(gatest.shape[0],napps))
print('Apps data: train shape {}, test shape {}'.format(Xtr_app.shape, Xte_app.shape))

applabels = applabels.loc[applabels.app_id.isin(appevents.app_id.unique())]
applabels['app'] = appencoder.transform(applabels.app_id)
labelencoder = LabelEncoder().fit(applabels.label_id)
applabels['label'] = labelencoder.transform(applabels.label_id)
nlabels = len(labelencoder.classes_)

devicelabels = (deviceapps[['device_id','app']]
                .merge(applabels[['app','label']])
                .groupby(['device_id','label'])['app'].agg(['size'])
                .merge(gatrain[['trainrow']], how='left', left_index=True, right_index=True)
                .merge(gatest[['testrow']], how='left', left_index=True, right_index=True)
                .reset_index())
devicelabels.head()

d = devicelabels.dropna(subset=['trainrow'])
Xtr_label = csr_matrix((np.ones(d.shape[0]), (d.trainrow, d.label)), 
                      shape=(gatrain.shape[0],nlabels))
d = devicelabels.dropna(subset=['testrow'])
Xte_label = csr_matrix((np.ones(d.shape[0]), (d.testrow, d.label)), 
                      shape=(gatest.shape[0],nlabels))
print('Labels data: train shape {}, test shape {}'.format(Xtr_label.shape, Xte_label.shape))

Xtrain = hstack((Xtr_brand, Xtr_model, Xtr_app, Xtr_label), format='csr')
Xtest =  hstack((Xte_brand, Xte_model, Xte_app, Xte_label), format='csr')
print('All features: train shape {}, test shape {}'.format(Xtrain.shape, Xtest.shape))

targetencoder = LabelEncoder().fit(gatrain.group)
y = targetencoder.transform(gatrain.group)

########## XGBOOST ##########

params = {}
params['booster'] = 'gblinear'
params['objective'] = "multi:softprob"
params['eval_metric'] = 'mlogloss'
params['eta'] = 0.005
params['num_class'] = 12
params['lambda'] = 3
params['alpha'] = 2

# Random 10% for validation
kf = list(StratifiedKFold(y, n_folds=10, shuffle=True, random_state=4242))[0]

Xtr, Xte = Xtrain[kf[0], :], Xtrain[kf[1], :]
ytr, yte = y[kf[0]], y[kf[1]]

print('Training set: ' + str(Xtr.shape))
print('Validation set: ' + str(Xte.shape))

d_train = xgb.DMatrix(Xtr, label=ytr)
d_valid = xgb.DMatrix(Xte, label=yte)

watchlist = [(d_train, 'train'), (d_valid, 'eval')]

clf = xgb.train(params, d_train, 1000, watchlist, early_stopping_rounds=25)

pred = clf.predict(xgb.DMatrix(Xtest))

pred = pd.DataFrame(pred, index = gatest.index, columns=targetencoder.classes_)
pred.head()
pred.to_csv('sparse_xgb.csv', index=True)

#params['lambda'] = 1
#for alpha in [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]:
#    params['alpha'] = alpha
#    clf = xgb.train(params, d_train, 1000, watchlist, early_stopping_rounds=25)
#    print('^' + str(alpha))

```

# 12.Tip

（1）含有缺失进行训练

```python
dtrain = xgb.DMatrix(x_train, y_train, missing=np.nan）
```

# 13.参考文献

（1）[xgboost导读和实战](http://pan.baidu.com/s/1gfA6FK3)

（2）[xgboost](http://pan.baidu.com/s/1eR7ADge)

（3）[自定义目标函数](https://github.com/dmlc/xgboost/blob/master/demo/guide-python/custom_objective.py)

（4）[机器学习算法中GBDT和XGBOOST的区别有哪些？](https://www.zhihu.com/question/41354392)

（5）[DART](http://xgboost.readthedocs.io/en/latest/tutorials/dart.html) 

（6）[https://www.kaggle.com/anokas/sparse-xgboost-starter-2-26857/code](https://www.kaggle.com/anokas/sparse-xgboost-starter-2-26857/code)

（7）[XGBoost: Reliable Large-scale Tree Boosting System](http://learningsys.org/papers/LearningSys_2015_paper_32.pdf)

（8）[XGBoost: A Scalable Tree Boosting System](http://delivery.acm.org/10.1145/2940000/2939785/p785-chen.pdf?ip=202.118.228.100&id=2939785&acc=ACTIVE%20SERVICE&key=BF85BBA5741FDC6E.5C4511229FC427D6.4D4702B0C3E38B35.4D4702B0C3E38B35&CFID=905733202&CFTOKEN=53852884&__acm__=1488265641_ffdebf36cef2b1bf7f3f76abf6bfe426)
