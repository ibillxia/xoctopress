---   
layout: page   
title: "About Me"   
date: 2026-07-03 10:46   
comments: true   
sharing: false   
footer: true   
---   
   
<center>{% img /images/bg_zju.png %}</center>   
   
## 个人概览 Profile   
高级数据科学家，10+ 年腾讯 / 腾讯音乐工作经验，3+ 年团队管理经验。      
   
- **GenAI & Agent**   
把音乐 AI 助手升级为 ReAct + Tool Calling 的自主 Agent，带全链路可观测，回答准确率 +20%、卡片 CTR +50%；   
在 vLLM 推理上做调优并向 HuggingFace transformers 提交 issue；   
沉淀 TMEDevLoop 工程提效 Skill，vibe coding 效率 +70%。      
   
- **Recommendation & Advertising**   
迭代音乐推荐召回与排序模型，完播率与收藏转化 +5%；   
主导 B 端内容推广投放系统从 0 到亿级 ARR，服务于环球音乐、索尼音乐、腾讯游戏等厂牌，以及上万独立音乐人，两次获得公司业务突破奖。      
   
- **Data Science & Engineering**   
通过爆款潜力评估模型挖掘并推火《一路生花》等现象级歌曲；   
从 0 到 1 搭建离线 + 流式数据管道，支撑离线、实时更新的音乐榜单。      
   
## 核心技能 Core Skills   
•	GenAI & Agent: ReAct、Tool Calling、Multi-Agent、Prompt 工程、评测 Pipeline、全链路可观测、Skill、Go服务开发。  
•	推荐算法与机器学习: 召回 / 精排 / 重排 · DeepFM / DIN / DCN / EPNet / OneTrans · CLIP, Qwen3-Embedding · Faiss 向量检索 · 冷启动。    
•	实验设计&因果推断: 双边市场的A/B 实验设计 · 倾向得分匹配 / IPW · Uplift Modeling。   
•	数据栈: SQL (Hive) · Python (pandas, scikit-learn, PyTorch / TensorFlow) · Spark / Flink / Kafka · Elasticsearch / HBase / MySQL。   
   
## 技术影响力 Speaking & Influence   
•	2025.06 · 开源贡献 · 发现HuggingFace transformers项目的一个 TorchTensorParallelPlugin 相关的bug [issue](https://github.com/huggingface/transformers/issues/39077)    
•	2023.09 · 北京·人人都是产品经理大会 · 《AI + 内容精细化运营下的产品增长》 [link](https://www.woshipm.com/event/5895272.html)    
•	2022.04 · 上海(Online) · A2M 大会 · 《数据科学在音乐推荐中的实践和应用》 [link](https://a2m.msup.com.cn/course/15492?_a2m_nocache=1783047050732&aid=4949&city=shanghai)    
•	2021.10 · 深圳(Online) · DataFunTalk · 《内容评估理解和流量精细化运营》[link](https://mp.weixin.qq.com/s/SaJcVARQzUSpPj2uugXypA)    
   
## 工作 & 教育经历 Experience & Education   
•	腾讯音乐 (TME / QQ 音乐)  ·  数据科学家 / 数科管理岗	2016.10 – 至今   
•	腾讯 (Tencent)  ·  数据分析师	2015.04 – 2016.09   
•	浙江大学 (C9)  ·  计算机科学与技术 硕士	2012.09 – 2015.04   
•	华中农业大学 (211)  ·  计算机科学与技术 学士	2008.09 – 2012.06   
   
## 主要项目经历 Key Projects   
### 1. 生产级 Agent、全链路可观测与主动触达	2025 – 2026   
•	资产Agent (Tool Calling + ReAct): 把基于意图识别+Workflow的音乐资产助手升级为自主Agent，封装资产获取 / 数据统计 / 数据筛选 / 用户画像查询为标准化 Tool，搭建 Tool Schema 校验、失败降级与回答评测 Pipeline — 准确率 +20%。   
•	全链路可观测: 覆盖工具调用链、token / latency / cost、检索命中率、最终回答准确率与安全性。   
•	主动触达: 行为历史 + 兴趣时钟 + 听歌月报 / 年报 → trigger 召回、模板变量填充、多维打分排序、频控、发送时间选择 — 端到端 A/B 测试的主动对话系统。   
   
### 2. 推荐召回与排序升级  ·  多模态表征 + 多样性重排	2024 – 2026   
•	长音频精排: 基于EPNet等算法的多个排序策略和模型的升级 — 曝光→播放转化、播放时长、收藏 +5%，拉动下游留存与北极星指标提升。   
•	多模态召回: CLIP 图文特征 + Qwen3-Embedding 歌词向量基于 Faiss 向量库构建召回服务，图文表征用于封面精排模型的特征 — 渗透与播放时长 +3%。   
•	多样性与生态健康: 歌单重排引入语种 / 流派 / 歌手多维频控 — 显著提升新歌单播放与收藏渗透，沉淀为通用重排组件。   
   
### 3. 音乐推流 0 → 亿级 ARR  ·  服务于全球厂牌与创作者	2021 – 2026   
•	业务成就: 音乐投放收入从 0 到亿级 ARR突破，两度获得公司级业务突破奖，在厂牌供给、听众需求和平台商业化之间找到长期平衡点。   
•	度量体系架构: 设计双边市场 A/B 实验，对投放任务（内容）x用户的交叉维度进行分流，同时评估任务进度控制策略优化的收益和对用户听歌指标的影响。   
•	因果推断: 对无法评估同一个用户投放、不投放情况下的时长、留存情况，使用 Uplift Modeling 把投放预算分配到真正增量的曝光上。   
•	模型与排序: 排序模型从 XGBoost 演进到 DIN / DCN / MMOE，引入跨场景建模与生成式推荐解决冷启动；库存利用率&任务完成率 +10%，同时保障听众体验无显著负向影响。   
•	数据闭环: 实时回收投放的下发、播放、收藏等行为数据，设计多轮赛马投放、多点位分级流转、点位熔断机制等策略，保障任务进度和用户体验。   
   
### 4. 推荐系统流量调控  ·  流量调控内容中台	2019 – 2026   
•	业务成果: 优势版权内容、付费内容播放份额提升x%，用户留存、会员转化提升x%；翻唱、盗版等内容份额下降x%；价值评估结果作为推荐模型重要特征，消融实验显示对时长影响1%+；多次获公司级奖项。   
•	内容价值评估: 构建离线、实时统计的内容互动转化效率、拉新拉活能力、商业化驱动价值等多维度评估体系，融合内容的语种、年代、流派、厂牌等基础属性。   
•	流量调控中台：支持内容池配置、内容加权公式配置、流量调控点位配置等，实现对推荐等可控点位在粗精排阶段内容打分的干预，扶持或打压相关属性的内容。   
   
### 5. 潜力热歌挖掘  ·  多模态内容理解 + 前瞻行为画像	2019 – 2021   
•	成果: 挖掘并推火《一路生花》等现象级歌曲，获公司级创新奖、业务突破奖等。   
•	内容挖掘: 融合歌词 / 音频等多模态信号和站内前瞻用户行为数据，构建爆款潜力打分模型；挖掘的优质内容，在它还处于长尾流量时，提前进行版权锁定。
•	站内外宣发: 联合站内、站外流量，进行多轮赛马筛选和验证，站内先进行3～5轮流量验证，再联合站外达人进行推广。   
•	拉新拉活: 站外宣发的内容，在评论区引导用户使用QQ音乐收听完整版，带来新回流用户，提升大盘DAU和留存。   
   
### 6. 数据可视化平台  ·  0 → 1，全栈开发	2015 – 2018   
•	大盘实时监控: 分终端实时播放量，实时累计top歌曲，实时播放人群分布（如性别、年龄段、地域省份）等数据统计和监控展示。   
•	内容分析: 按歌曲、专辑、歌手、厂牌等维度的播放量、下载量、收藏量等数据趋势，内容的播放用户人群分布，不同内容的数据对比分析；版权结算和预算数据统计与预估，结算合同规则录入与结算公式自动化。   
•	用户分群: 基于多种用户画像维度（基础属性、活跃于操作行为、音乐偏好等）进行人群圈选，用于下游运营（如push、内容运营、会员活动等）。   
•	技术栈: 计算 HiveSQL / Flink · 存储 ES / HBase / MySQL · 可视化 HTML / D3.js / Echarts。   
   
## 其他项目 Selected Side Projects   
### Sovits-SVC AI 翻唱:    
RTX 4060 本地全流程 hands-on，涵盖人声 / 伴奏分离、切片、训练、推理，生成周杰伦 / 孙燕姿等音色微调模型。   
   
### 基于 Gemma 的端侧音乐 App(Kotlin):    
Gemma 4 端侧模型解析多模态(摄像头 + 麦克风 + GPS)输入，对话式推荐 + AI DJ 电台 TTS，整合 iTunes / Deezer / Last.fm等平台API，支持本地音乐扫描与听歌周报生成。   
   
### 跨端 AI 日报 App (TypeScript):    
数据源 / LLM / 平台发布全链路可配置，自动生成日报并发布至 GitHub Pages / 公众号。   
   
### Spotify 资讯日报 Skill:    
聚合 9+ 信息源，下载量 530+ — clawhub.ai/ibillxia/spotify-news-digest   
   
   
## 我的网络社交     
【[StackOverFlow](http://stackoverflow.com/users/1602285/bill-xia)】  
【[GitHub](https://github.com/ibillxia)】  
【[Facebook](https://www.facebook.com/ibillxia)】   
【[Tiwtter](https://twitter.com/ibillxia)】      
【[新浪微博](http://weibo.com/ibillxia)】  
【[豆瓣](http://www.douban.com/people/ibillxia/)】  
【[知乎](http://www.zhihu.com/people/ibillxia)】     
   
   
## 联系我     
E-mail(G+/Hangouts): ibillxia AT gmail DOT com.      
