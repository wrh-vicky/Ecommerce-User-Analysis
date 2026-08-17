# SmartBuy 电商用户增长与转化分析

> 基于 SQL、Python、MySQL 与 Power BI
> 的电商用户行为分析项目，围绕购买转化问题，完成原始数据处理、数仓分层、业务分析、高潜
> Session 识别、购买预测与 BI Dashboard 展示。

## 0. BI报表

### Page 1 — Executive Overview

### Page 2 — Behavior & Conversion

### Page 3 — High Potential Sessions


## 1. 项目背景

SmartBuy 平台访问量增长，但购买增长相对不足。本项目基于用户 Session
行为数据，分析影响购买转化的潜在因素，识别关键转化环节与高潜
Session，为产品、运营和渠道优化提供数据支持。

核心问题包括：

-   平台整体购买转化情况如何？
-   新访客与回访访客的转化是否不同？
-   商品浏览深度、停留时间与购买有什么关系？
-   BounceRates、ExitRates、PageValues 与购买结果有什么关系？
-   哪些 Session 已表现出较强购买意向但最终没有购买？
-   规则法与模型法能否进一步识别高潜 Session？
-   如何将验证后的指标沉淀到 DWS / ADS 并供 Power BI 使用？

``` text
Raw Data → ODS → DWD → SQL Analysis → Python EDA
→ Session Segmentation → High Potential Analysis
→ Purchase Prediction → DWS → ADS → Power BI
```

------------------------------------------------------------------------

## 2. 数据集与指标口径

项目使用 **Online Shoppers Purchasing Intention Dataset**。

``` text
一行 = 一次网站访问 Session
```

因此 12,330 条记录表示 12,330 个 Session，而不是 12,330 个独立用户。

  指标                          结果
  ------------------------- --------
  Total Sessions              12,330
  Purchase Sessions            1,908
  Session Conversion Rate     15.47%

主要字段：

  字段                      含义
  ------------------------- ---------------------------
  Administrative            行政类页面访问次数
  Administrative_Duration   行政类页面停留时间
  Informational             信息类页面访问次数
  Informational_Duration    信息类页面停留时间
  ProductRelated            商品页面访问次数
  ProductRelated_Duration   商品页面停留时间
  BounceRates               跳出率
  ExitRates                 退出率
  PageValues                页面价值
  SpecialDay                特殊日期指数
  Month                     月份
  OperatingSystems          操作系统
  Browser                   浏览器
  Region                    地区
  TrafficType               流量类型
  VisitorType               新访客/回访访客
  Weekend                   是否周末
  Revenue                   本次 Session 是否最终购买

完整字段说明见 `docs/data_dictionary.md`。

------------------------------------------------------------------------

## 3. 技术栈

-   **数据库与 SQL：** MySQL、SQL
-   **Python：** Pandas、NumPy、Matplotlib、Scikit-learn
-   **模型：** Logistic Regression、Random Forest
-   **数据库连接：** SQLAlchemy、PyMySQL
-   **BI：** Power BI
-   **开发环境：** Jupyter Notebook、Git、GitHub

------------------------------------------------------------------------

## 4. 数据架构

``` text
CSV
 ↓
ODS
 ↓
DWD
 ↓
DWS
 ↓
ADS
 ↓
Power BI
```

### ODS

承接原始 CSV，完成数据量、空值、重复值、字段范围和类别值等基础质量检查。

### DWD

对 Session 数据进行标准化并生成基础衍生字段，例如：

``` text
session_id
month_num
visitor_type_name
is_weekend
is_purchase
total_page_views
total_page_duration
product_view_ratio
```

DWD 保持"一行 = 一个 Session"，作为 SQL、Python
和后续聚合的统一明细数据源。

### DWS

主要主题汇总表：

``` text
dws_monthly_conversion
dws_visitor_type_conversion
dws_traffic_type_conversion
dws_product_depth_conversion
dws_product_duration_conversion
dws_proxy_funnel
dws_session_segment_summary
```

### ADS

面向 Dashboard 输出：

``` text
ads_core_kpi
ads_monthly_dashboard
ads_channel_priority
ads_high_potential_rule
ads_high_potential_profile
```

------------------------------------------------------------------------

## 5. 分析流程

``` text
数据理解 → 数据质量检查 → ODS/DWD
→ SQL 业务分析 → Python EDA → 交叉分析
→ 相关性分析 → Session 分层 → 高潜识别
→ Logistic Regression → Random Forest
→ 规则法 × 模型法 → DWS/ADS → Power BI
```

------------------------------------------------------------------------

## 6. 核心分析结果

### 6.1 整体经营情况

``` text
Total Sessions       = 12,330
Purchase Sessions    = 1,908
Conversion Rate      ≈ 15.47%
```

约每 100 个 Session 中有 15 个最终产生购买。

### 6.2 新访客与回访访客

  VisitorType           Session   Purchase      CVR
  ------------------- --------- ---------- --------
  New Visitor             1,694        422   24.91%
  Returning Visitor      10,551      1,470   13.93%
  Other                      85         16   18.82%

Returning Visitor 的 Session 数量更多、浏览更深，但单次 Session CVR 低于
New Visitor。

#### VisitorType × 商品浏览深度

![VisitorType ×
商品浏览深度](images/03/conversion_rate_by_product_depth_and_visitor_type.png)

在多个商品浏览层级中，New Visitor CVR 仍高于 Returning Visitor。

> VisitorType
> 本身可能包含额外购买意向信息，新老访客的转化差异不能仅用浏览深度解释。

### 6.3 商品浏览深度

#### 购买 vs 未购买 Session 商品浏览差异

![购买与未购买 Session 商品浏览差异](images/02/product_view.png)

``` text
购买 Session：平均 ProductRelated = 48.21，中位数 = 29
未购买 Session：平均 ProductRelated = 28.71，中位数 = 16
```

按商品浏览次数分组：

  浏览次数     Session   Purchase      CVR
  ---------- --------- ---------- --------
  0--5           2,369        102    4.31%
  6--10          1,804        185   10.25%
  11--20         2,560        392   15.31%
  21--50         3,445        685   19.88%
  50+            2,152        544   25.28%

#### 商品浏览深度 × CVR

![商品浏览深度与转化率](images/02/product_view_conversion.png)

CVR 从 0--5 次浏览组的 4.31% 持续提高至 50+ 组的 25.28%。

> 商品浏览深度与购买意向存在明显正向关联，但属于相关关系，不能直接解释为因果关系。

### 6.4 商品页面停留时间

  停留时间       Session   Purchase      CVR
  ------------ --------- ---------- --------
  0--2 min         2,361         94    3.98%
  2--5 min         1,807        133    7.36%
  5--10 min        2,006        308   15.35%
  10--20 min       2,376        482   20.29%
  20+ min          3,780        891   23.57%

![商品停留时间与转化率](images/02/product_duration_group.png)

商品页面停留时长与购买转化呈较稳定的正向关系，从 0--2 分钟组的 3.98%
上升至 20 分钟以上组的 23.57%。

### 6.5 BounceRates / ExitRates

``` text
BounceRates
未购买 Mean = 0.0253
购买   Mean = 0.0051

ExitRates
未购买 Mean = 0.0474
购买   Mean = 0.0196
```

购买 Session 整体具有更低的 BounceRates 和 ExitRates。

### 6.6 PageValues 与相关性

``` text
未购买 Session PageValues Mean = 1.976
购买 Session PageValues Mean   = 27.265
```

Revenue 相关性：

  Feature                     Correlation
  ------------------------- -------------
  PageValues                       +0.493
  ProductRelated                   +0.159
  ProductRelated_Duration          +0.152
  BounceRates                      -0.151
  ExitRates                        -0.207

![核心行为变量相关性热力图](images/02/correlation_heatmap.png)

PageValues 与 Revenue 的线性相关性明显强于其他核心行为变量。

> 相关性只能说明统计关联，不能直接证明因果关系。

------------------------------------------------------------------------

## 7. 高潜 Session 分析

由于数据没有真实 `user_id`，本项目严格使用 **High Potential
Sessions**，而不是 High Potential Users。

### 7.1 P75 规则

``` text
ProductRelated P75 = 38

High Potential:
ProductRelated >= 38
AND Revenue = False
```

共识别：

``` text
2,376 High Potential Sessions
```

  指标                        High Potential   All Non-Purchase
  ------------------------- ---------------- ------------------
  BounceRates                       0.007614           0.025317
  ExitRates                         0.021814           0.047378
  PageValues                        4.182961           1.975998
  ProductRelated_Duration        2941.962073        1069.987809

高潜 Session 商品页平均停留约 49 分钟，是全部未购买 Session 的约 2.75
倍；PageValues 约为普通未购买 Session 的 2.1 倍，同时 BounceRates 和
ExitRates 更低。

这说明该群体不是低兴趣快速流失
Session，而是已经表现出较强参与度但最终没有完成购买的 Session。

### 7.2 月份与渠道

November 高潜未购买 Session 绝对数量最多，为 690；August 高潜率最高，为
33.05%。月份分析因此需要同时观察高潜规模和高潜率。

TrafficType 2 同时具有较大的高潜 Session
规模和较高的高潜率。对于样本量很小的渠道，即使高潜率较高，也不能仅根据比例判断渠道质量。

------------------------------------------------------------------------

## 8. 购买预测模型

### 8.1 Logistic Regression

使用 Logistic Regression 作为可解释 Baseline，主要特征包括：

``` text
Administrative
Administrative_Duration
Informational
Informational_Duration
ProductRelated
ProductRelated_Duration
BounceRates
ExitRates
PageValues
SpecialDay
```

目标变量为 `Revenue`，训练/测试集按 80% / 20% 划分并使用 `stratify=y`。

第一版 `StandardScaler + LogisticRegression(class_weight="balanced")` 的
ROC-AUC 约为 0.8647。

### 8.2 PageValues A/B 实验

为了验证 PageValues 对预测能力的影响：

``` text
Model A：包含 PageValues
Model B：删除 PageValues
```

  Model                  Accuracy   Precision   Recall       F1   ROC-AUC
  -------------------- ---------- ----------- -------- -------- ---------
  With PageValues          0.8763      0.7200   0.3298   0.4524    0.8695
  Without PageValues       0.8443      0.4375   0.0183   0.0352    0.6679

![PageValues A/B 实验 ROC 曲线](images/03/roc_curve.png)

加入 PageValues 后 ROC-AUC 从 0.6679 提高到 0.8695，提升约 0.2016。

> 实际部署前需要确认 PageValues
> 在预测时点是否已经可获得，避免潜在的数据泄漏。

### 8.3 Confusion Matrix

![Logistic Regression Confusion Matrix](images/03/confusion_matrix.png)

``` text
TN：实际没买，模型也预测没买
FP：实际没买，模型预测会买
FN：实际买了，模型预测不买
TP：实际买了，模型也预测会买
```

高潜识别场景需要特别关注 FN，因为 FN 越多，意味着遗漏的真实购买 Session
越多。

### 8.4 Logistic Regression ROC Curve

![Logistic Regression ROC
Curve](images/03/roc_curve_logistic_regression.png)

Model A ROC-AUC 约为 0.869，说明模型对购买与未购买 Session
具有较好的整体区分能力。

### 8.5 Random Forest

Random Forest ROC-AUC 约为 0.889，高于 Logistic Regression 约
0.869，说明非线性关系和变量交互能够提供一定额外预测能力。

  Feature                     Importance
  ------------------------- ------------
  PageValues                      0.4288
  ExitRates                       0.1253
  ProductRelated_Duration         0.1244
  ProductRelated                  0.0869
  BounceRates                     0.0704
  Administrative_Duration         0.0678
  Administrative                  0.0416
  Informational_Duration          0.0282
  Informational                   0.0172
  SpecialDay                      0.0094

![Random Forest Feature Importance](images/03/feature_importance.png)

形成一致证据链：

``` text
EDA：PageValues 与 Revenue 相关性最强
        ↓
Logistic A/B：删除 PageValues 后性能明显下降
        ↓
Random Forest：PageValues Feature Importance 排名第一
```

------------------------------------------------------------------------

## 9. 规则法 × 模型法高潜识别

模型购买倾向评分采用 P90：

``` text
P90 = 0.833762
```

模型法定义：

``` text
PurchaseProbability >= P90
AND Revenue = False
```

结果：

``` text
规则法高潜：2,376
模型法高潜：356
重合 Both：188
Rule Only：2,188
Model Only：168
```

### Rule Only

2,188 个 Session：浏览很深，但综合模型购买倾向未进入 Top 10%。

### Model Only

168 个 Session，平均商品浏览约 23.34 次，但：

``` text
PageValues ≈ 43.22
购买倾向评分 ≈ 0.946
```

说明模型能够补充单一高浏览规则遗漏的潜在购买 Session。

### Both / Core High Potential

188 个 Session 同时满足：

``` text
P75 高浏览
+
Model Top 10%
+
最终未购买
```

该群体平均：

``` text
ProductRelated          ≈ 130.80
ProductRelated_Duration ≈ 88.2 min
Purchase Propensity     ≈ 0.935
```

因此将其定义为 **Core High Potential Sessions**。

------------------------------------------------------------------------

## 10. 模型阈值与业务目标

模型分类不能机械使用默认 `threshold = 0.5`。

![分类阈值与 Precision Recall F1](images/03/precision_recall_f1.png)

当前候选阈值中：

``` text
Threshold = 0.2
F1        ≈ 0.5959
Recall    ≈ 60.99%
Precision ≈ 58.25%
```

相比默认 0.5：

``` text
Recall:    32.98% → 60.99%
Precision: 72.00% → 58.25%
```

-   **低成本触达**：Email、Push、站内推荐，可适当降低阈值提高 Recall。
-   **高成本触达**：优惠券、人工销售等，应更加关注 Precision。

> 分类 Threshold 与 P90
> 高潜阈值不是同一概念。前者用于将概率转换为分类结果，后者用于从实际未购买
> Session 中筛选最值得运营关注的 Top 10%。

------------------------------------------------------------------------

## 11. Session 运营分层

  优先级   Session                         数量 建议
  -------- ---------------------------- ------- --------------------------------------------
  P1       Core High Potential / Both       188 优先分析转化阻碍，重点触达
  P2       Model Only                       168 模型高意向群体，精准触达
  P3       Rule Only                      2,188 高参与但购买信号较弱，低成本运营或继续观察

不应把所有"浏览很多但没有购买"的 Session
视为同样高价值，应结合浏览、停留、退出、PageValues
和模型评分进行优先级划分。

------------------------------------------------------------------------

## 12. Proxy Funnel

原始数据为 Session
级聚合数据，没有完整事件时间序列，因此没有人为构造标准电商漏斗。

本项目使用代理行为漏斗：

``` text
All Sessions
↓
Product View
↓
Deep Product View
↓
Purchase
```

> Proxy Funnel 用于辅助观察行为深度变化，不等同于真实的 View → Add Cart
> → Checkout → Payment → Purchase 事件漏斗。

------------------------------------------------------------------------

## 13. Power BI Dashboard

经过验证的指标沉淀到 DWS / ADS 后，由 Power BI
消费。由于报表页面较长，README 将每页拆为关键区域截图。

> 将实际截图放到 `images/dashboard/`。如果文件名不同，请修改下列路径。

### Page 1 --- Executive Overview

主要展示 Total Sessions、Purchase Sessions、CVR、High Potential
Sessions、月度趋势、VisitorType CVR 和 Product View Depth CVR。

![Executive Overview - KPI and Trend](images/dashboard/overview_01.png)

![Executive Overview - Conversion
Analysis](images/dashboard/overview_02.png)

### Page 2 --- Behavior & Conversion

主要展示
ProductRelated、ProductRelated_Duration、BounceRates、ExitRates、PageValues、VisitorType
与 Session Segment。

![Behavior and Conversion -
Engagement](images/dashboard/behavior_01.png)

![Behavior and Conversion - Conversion
Signals](images/dashboard/behavior_02.png)

### Page 3 --- High Potential Sessions

主要展示 High Potential Volume、High Potential
Rate、月份、TrafficType、高潜画像与 Session Segment。

![High Potential Sessions -
Overview](images/dashboard/high_potential_01.png)

![High Potential Sessions - Profile and
Channel](images/dashboard/high_potential_02.png)

------------------------------------------------------------------------

## 14. 核心业务结论

1.  商品浏览深度与购买转化存在明显正向关联，CVR 从 4.31% 提升至 25.28%。
2.  商品页面停留时间与购买转化呈稳定正向关系，CVR 从 3.98% 提升至
    23.57%。
3.  购买 Session 整体具有更低的 BounceRates 和 ExitRates。
4.  New Visitor CVR 约 24.91%，Returning Visitor 约
    13.93%，且差异不能仅由浏览深度解释。
5.  PageValues 是当前数据最重要的购买预测信号之一。
6.  单一高浏览规则无法完整识别高购买倾向 Session，模型补充识别出 168 个
    Model Only Session。
7.  规则法与模型法共同识别出的 188 个 Both Session 是最值得关注的 Core
    High Potential Sessions。
8.  模型分类阈值应服务于业务目标：低成本触达更关注
    Recall，高成本触达更关注 Precision。
9.  当前结论属于相关关系与预测关系，不能直接证明最终未购买的因果原因。

------------------------------------------------------------------------

## 15. 业务建议

### 分层运营

使用 P1 / P2 / P3 体系，将分析和运营资源优先投入 Core High Potential
Sessions。

### 补充真实转化事件

未来建议增加：

``` text
Add to Cart
Checkout
Payment
Coupon / Promotion
Price
Inventory
Product
Category
```

进一步定位商品、价格、优惠、库存、支付和页面体验等真实转化阻碍。

### 渠道评估同时考虑规模与效率

``` text
Session Volume
+
Conversion Rate
+
High Potential Volume
+
High Potential Rate
+
Marketing Cost
+
Expected Revenue
```

### 根据触达成本选择模型阈值

低成本触达可提高 Recall；高成本触达应更加关注 Precision。

------------------------------------------------------------------------

## 16. 数据质量与指标一致性

### ODS

-   数据量检查
-   空值检查
-   重复值检查
-   字段范围检查
-   类别值检查

### DWD

-   Session ID 唯一性
-   页面访问次数非负
-   Duration 非负
-   比例字段范围检查
-   Month 标准化
-   Revenue → is_purchase 映射检查

### DWD → DWS → ADS

验证：

``` text
SUM(DWS session_cnt) = DWD Total Sessions
SUM(DWS purchase_cnt) = DWD Purchase Sessions
```

并继续进行 DWS → ADS 指标对账，保证 Dashboard 与底层数据口径一致。

------------------------------------------------------------------------

## 17. 项目目录

``` text
ecommerce-user-analysis/
├── data/
│   ├── raw/
│   └── processed/
├── sql/
├── python/
├── docs/
│   ├── data_dictionary.md
│   └── analysis_report.md
├── dashboard/
├── images/
│   ├── 02/
│   │   ├── product_view.png
│   │   ├── product_view_conversion.png
│   │   ├── product_duration_group.png
│   │   └── correlation_heatmap.png
│   ├── 03/
│   │   ├── conversion_rate_by_product_depth_and_visitor_type.png
│   │   ├── roc_curve.png
│   │   ├── confusion_matrix.png
│   │   ├── roc_curve_logistic_regression.png
│   │   ├── precision_recall_f1.png
│   │   └── feature_importance.png
│   └── dashboard/
│       ├── overview_01.png
│       ├── overview_02.png
│       ├── behavior_01.png
│       ├── behavior_02.png
│       ├── high_potential_01.png
│       └── high_potential_02.png
└── README.md
```

> SQL、Notebook 和 Power BI 的具体文件名请以本地项目实际目录为准。

------------------------------------------------------------------------

## 18. 如何运行

### Step 1：准备 MySQL

``` sql
CREATE DATABASE ecommerce_analysis;
```

导入原始 CSV 数据。

### Step 2：执行 SQL

按项目 `sql/` 目录中的建库、质量检查、DWD、业务分析以及 DWS/ADS ETL
脚本顺序执行。

### Step 3：运行 Python Notebook

按数据探索 → 业务 EDA → Session 分层/模型 → DWS/ADS → Power BI
数据准备的顺序运行。

每个 Notebook 应独立导包、读取数据并建立数据库连接，不依赖前一个
Notebook 的内存变量。

### Step 4：Power BI

推荐链路：

``` text
MySQL → DWS / ADS → Power BI → Dashboard
```

Power BI 优先消费经过验证的指标层，而不是重新从原始 CSV 计算全部指标。

------------------------------------------------------------------------

## 19. 项目亮点

-   **完整分析链路：** 数据导入 → 数据质量 → 数仓分层 → SQL → Python EDA
    → 模型 → DWS/ADS → Power BI。
-   **SQL / Python / BI 分工明确：** SQL 负责数据处理和聚合，Python 负责
    EDA 与建模，Power BI 负责业务展示。
-   **同时关注规模与效率：** 不只看 Session Count，也比较 Purchase
    Count、CVR、High Potential Rate。
-   **规则法 × 模型法：** P75 业务规则与模型 Top 10% 购买倾向结合。
-   **强调口径严谨性：** Session ≠ User、相关性 ≠ 因果、Proxy Funnel ≠
    Event Funnel、Prediction Score ≠ 真实购买概率。
-   **分析与数据开发结合：** 将验证后的指标沉淀到 ODS → DWD → DWS →
    ADS。

------------------------------------------------------------------------

## 20. 项目局限性

1.  数据粒度是 Session，不是独立 User。
2.  缺少 `user_id`，无法识别同一用户的多次访问。
3.  缺少完整事件时间序列，无法构建标准电商事件漏斗。
4.  缺少 Add to Cart、Checkout、Payment 等关键事件。
5.  缺少价格、优惠、库存、物流等业务变量。
6.  PageValues
    对模型贡献很大，实际部署前需确认预测时点是否可获得，避免数据泄漏。
7.  `predict_proba()`
    在当前项目主要作为购买倾向评分，不应直接解释为经过校准的真实购买概率。
8.  当前分析主要发现相关关系与预测关系，不能直接证明因果关系。

------------------------------------------------------------------------

## 21. 后续优化

``` text
事件级行为数据
→ 标准电商漏斗
→ 用户级行为宽表
→ RFM / 用户生命周期
→ 商品 / 品类分析
→ 营销归因
→ 模型评分落库
→ 定时 ETL
→ Power BI 自动刷新
```

还可以进一步增加：

-   增量 ETL
-   数据质量监控
-   Airflow / DolphinScheduler
-   Out-of-Fold Prediction
-   Probability Calibration
-   SHAP
-   A/B Test
-   营销 ROI 分析

------------------------------------------------------------------------

## 22. 项目总结

本项目围绕"为什么大量 Session 没有最终完成购买"这一业务问题，完成：

``` text
数据处理
+
SQL 业务分析
+
Python EDA
+
Session 行为分层
+
高潜 Session 识别
+
购买倾向预测
+
DWS / ADS 指标沉淀
+
Power BI Dashboard
```

商品浏览深度、商品页面停留时间、BounceRates、ExitRates、PageValues 和
VisitorType 均与购买行为表现出不同程度的关联。

进一步将 P75 高浏览规则与模型 Top 10% 购买倾向交叉，识别出 **188 个 Core
High Potential Sessions**，用于模拟更精细的运营优先级划分。

最终形成：

``` text
发现问题
↓
分析问题
↓
验证问题
↓
识别机会
↓
形成指标
↓
沉淀数据层
↓
Dashboard 展示
↓
支持业务决策
```
