# 数据字典

## 字段级解释

| 字段                      | 中文含义     | 类型 | 业务含义            |
| ----------------------- | -------- | -- | --------------- |
| Administrative          | 行政页面访问次数 | 数值 | 用户访问行政类页面次数     |
| Administrative_Duration | 行政页面停留时间 | 数值 | 用户在行政类页面停留时间    |
| Informational           | 信息页面访问次数 | 数值 | 用户访问信息类页面次数     |
| Informational_Duration  | 信息页面停留时间 | 数值 | 用户在信息类页面停留时间    |
| ProductRelated          | 商品页面访问次数 | 数值 | 用户访问商品相关页面次数    |
| ProductRelated_Duration | 商品页面停留时间 | 数值 | 用户在商品页面停留时间     |
| BounceRates             | 跳出率      | 数值 | 页面跳出相关指标        |
| ExitRates               | 退出率      | 数值 | 页面退出相关指标        |
| PageValues              | 页面价值     | 数值 | 页面对购买的价值贡献      |
| SpecialDay              | 特殊日期指数   | 数值 | 与特殊节日的接近程度      |
| Month                   | 月份       | 类别 | 用户访问月份          |
| OperatingSystems        | 操作系统     | 类别 | 用户使用的操作系统       |
| Browser                 | 浏览器      | 类别 | 用户使用的浏览器        |
| Region                  | 地区       | 类别 | 用户地区            |
| TrafficType             | 流量类型     | 类别 | 用户流量来源类型        |
| VisitorType             | 用户类型     | 类别 | 新用户/回访用户        |
| Weekend                 | 是否周末     | 布尔 | 是否在周末访问         |
| Revenue                 | 是否购买     | 布尔 | 本次Session是否最终购买 |

---

## 数据层级解释

### 数据仓库分层说明

| 数据层 | 解释 |
| ODS（Operational Data Store）原始数据层 | 用于保存业务系统采集的原始数据，保持源数据结构和内容，不进行复杂业务加工，主要用于数据留存、追溯以及后续数据处理 |
| DWD（Data Warehouse Detail）明细数据层 | 对ODS层数据进行清洗、标准化和字段加工后的明细数据层。该层保证数据质量，并形成可直接用于业务分析的基础明细数据 |
| DWS（Data Warehouse Service）汇总服务层 | 对DWD明细数据按照业务主题进行聚合计算，形成面向分析场景的指标数据，减少重复计算，提高查询效率 |
| ADS（Application Data Service）应用数据层 | 面向业务应用和展示场景的数据层，将DWS中的指标进一步加工成业务报表、Dashboard所需的数据集 |
| Dashboard数据层 | 为BI工具提供可视化分析数据，帮助业务人员快速了解经营情况、发现问题并辅助决策 |

---

## 表级解释

| 表名 | 中文名称 | 数据层 | 数据粒度 | 表说明 | 用途 |
| ods_online_shoppers | 原始购物访问表 | ODS | Session | 保存原始访问行为数据 | 数据留存 |
| dwd_user_session | 用户访问行为明细表 | DWD | Session | 清洗加工后的行为明细数据 | SQL分析 |
| dws_session_behavior_analysis	Session | 行为汇总表 | DWS | 分析主题 | 用户行为指标聚合 | 业务分析 |
| dws_session_segment	Session | 分层表 | DWS | Session | 用户行为价值分层 | 高潜分析 |
| ads_dashboard_overview | 经营总览指标表 | ADS | 指标 | Dashboard展示数据 | BI展示 |
| ads_behavior_conversion_dashboard | 行为转化分析表 | ADS | 指标 | 行为与购买关系分析 | BI展示 |
| ads_high_potential_session | 高潜Session表 | ADS | Session | 高价值未购买分析 | 运营优化 |

