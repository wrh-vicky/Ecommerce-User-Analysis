-- ============================================================
-- 第6课：DWS + ADS + SQL ETL
-- 项目：ecommerce-user-analysis
-- 前置依赖：ecommerce_analysis.dwd_user_session 已存在且已完成第2课清洗
-- 说明：本脚本可重复执行；每次会重建本课 DWS/ADS 表。
-- ============================================================

USE ecommerce_analysis;

-- 0. 源数据检查
SELECT
    COUNT(*) AS dwd_rows,
    SUM(is_Purchase) AS purchase_sessions,
    ROUND(SUM(is_Purchase) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM dwd_user_session;

-- 1. DWS：月度经营汇总
DROP TABLE IF EXISTS dws_monthly_conversion;
CREATE TABLE dws_monthly_conversion AS
SELECT
    Month_Num,
    Month,
    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(SUM(is_Purchase) * 100.0 / COUNT(*), 2) AS conversion_rate,
    ROUND(AVG(ProductRelated), 2) AS avg_product_views,
    ROUND(AVG(ProductRelated_Duration), 2) AS avg_product_duration,
    ROUND(AVG(BounceRates), 4) AS avg_bounce_rate,
    ROUND(AVG(ExitRates), 4) AS avg_exit_rate,
    ROUND(AVG(PageValues), 2) AS avg_page_value
FROM dwd_user_session
GROUP BY Month_Num, Month;
ALTER TABLE dws_monthly_conversion
ADD PRIMARY KEY (Month_Num);

-- 2. DWS：访客类型汇总
DROP TABLE IF EXISTS dws_visitor_type_conversion;
CREATE TABLE dws_visitor_type_conversion AS
SELECT
    VisitorType,
    VisitorType_Name,
    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(SUM(is_Purchase) * 100.0 / COUNT(*), 2) AS conversion_rate,
    ROUND(AVG(ProductRelated), 2) AS avg_product_views,
    ROUND(AVG(ProductRelated_Duration), 2) AS avg_product_duration,
    ROUND(AVG(BounceRates), 4) AS avg_bounce_rate,
    ROUND(AVG(ExitRates), 4) AS avg_exit_rate,
    ROUND(AVG(PageValues), 2) AS avg_page_value
FROM dwd_user_session
GROUP BY VisitorType, VisitorType_Name;
ALTER TABLE dws_visitor_type_conversion
ADD PRIMARY KEY (VisitorType);

-- 3. DWS：流量渠道汇总
DROP TABLE IF EXISTS dws_traffic_type_conversion;
CREATE TABLE dws_traffic_type_conversion AS
SELECT
    TrafficType,
    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(SUM(is_Purchase) * 100.0 / COUNT(*), 2) AS conversion_rate,
    ROUND(
        SUM(is_Purchase) * 100.0 /
        NULLIF((SELECT SUM(is_Purchase) FROM dwd_user_session), 0),
        2
    ) AS purchase_share,
    ROUND(AVG(ProductRelated), 2) AS avg_product_views,
    ROUND(AVG(ProductRelated_Duration), 2) AS avg_product_duration,
    ROUND(AVG(PageValues), 2) AS avg_page_value
FROM dwd_user_session
GROUP BY TrafficType;
ALTER TABLE dws_traffic_type_conversion
ADD PRIMARY KEY (TrafficType);

-- 4. DWS：商品浏览深度汇总
DROP TABLE IF EXISTS dws_product_depth_conversion;
CREATE TABLE dws_product_depth_conversion AS
SELECT
    product_view_group,
    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(SUM(is_Purchase) * 100.0 / COUNT(*), 2) AS conversion_rate,
    ROUND(AVG(ProductRelated), 2) AS avg_product_views,
    ROUND(AVG(ProductRelated_Duration), 2) AS avg_product_duration,
    ROUND(AVG(PageValues), 2) AS avg_page_value
FROM (
    SELECT
        CASE
            WHEN ProductRelated <= 5 THEN '01_0-5'
            WHEN ProductRelated <= 10 THEN '02_6-10'
            WHEN ProductRelated <= 20 THEN '03_11-20'
            WHEN ProductRelated <= 50 THEN '04_21-50'
            ELSE '05_50+'
        END AS product_view_group,
        ProductRelated,
        ProductRelated_Duration,
        PageValues,
        is_Purchase
    FROM dwd_user_session
) t
GROUP BY product_view_group;
ALTER TABLE dws_product_depth_conversion
ADD PRIMARY KEY (product_view_group);

-- 5. DWS：商品停留时长汇总
DROP TABLE IF EXISTS dws_product_duration_conversion;
CREATE TABLE dws_product_duration_conversion AS
SELECT
    duration_group,
    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(SUM(is_Purchase) * 100.0 / COUNT(*), 2) AS conversion_rate,
    ROUND(AVG(ProductRelated), 2) AS avg_product_views,
    ROUND(AVG(ProductRelated_Duration), 2) AS avg_product_duration,
    ROUND(AVG(PageValues), 2) AS avg_page_value
FROM (
    SELECT
        CASE
            WHEN ProductRelated_Duration < 120 THEN '01_0-2min'
            WHEN ProductRelated_Duration < 300 THEN '02_2-5min'
            WHEN ProductRelated_Duration < 600 THEN '03_5-10min'
            WHEN ProductRelated_Duration < 1200 THEN '04_10-20min'
            ELSE '05_20min+'
        END AS duration_group,
        ProductRelated,
        ProductRelated_Duration,
        PageValues,
        is_Purchase
    FROM dwd_user_session
) t
GROUP BY duration_group;
ALTER TABLE dws_product_duration_conversion
ADD PRIMARY KEY (duration_group);

-- 6. DWS：代理漏斗
DROP TABLE IF EXISTS dws_proxy_funnel;
CREATE TABLE dws_proxy_funnel (
    stage_order INT PRIMARY KEY,
    stage_name VARCHAR(50) NOT NULL,
    session_cnt INT NOT NULL,
    stage_rate DECIMAL(10,2) NULL,
    drop_rate DECIMAL(10,2) NULL
);

INSERT INTO dws_proxy_funnel
(stage_order, stage_name, session_cnt, stage_rate, drop_rate)
SELECT
    1,
    '01_访问网站',
    COUNT(*),
    100.00,
    0.00
FROM dwd_user_session;

INSERT INTO dws_proxy_funnel
(stage_order, stage_name, session_cnt, stage_rate, drop_rate)
SELECT
    2,
    '02_浏览商品',
    SUM(ProductRelated > 0),
    ROUND(SUM(ProductRelated > 0) * 100.0 / COUNT(*), 2),
    ROUND((1 - SUM(ProductRelated > 0) * 1.0 / COUNT(*)) * 100, 2)
FROM dwd_user_session;

INSERT INTO dws_proxy_funnel
(stage_order, stage_name, session_cnt, stage_rate, drop_rate)
SELECT
    3,
    '03_深度浏览',
    SUM(ProductRelated >= 10),
    ROUND(
        SUM(ProductRelated >= 10) * 100.0 /
        NULLIF(SUM(ProductRelated > 0), 0),
        2
    ),
    ROUND(
        (1 - SUM(ProductRelated >= 10) * 1.0 /
        NULLIF(SUM(ProductRelated > 0), 0)) * 100,
        2
    )
FROM dwd_user_session;

INSERT INTO dws_proxy_funnel
(stage_order, stage_name, session_cnt, stage_rate, drop_rate)
SELECT
    4,
    '04_最终购买',
    SUM(is_Purchase),
    ROUND(
        SUM(is_Purchase) * 100.0 /
        NULLIF(SUM(ProductRelated >= 10), 0),
        2
    ),
    ROUND(
        (1 - SUM(is_Purchase) * 1.0 /
        NULLIF(SUM(ProductRelated >= 10), 0)) * 100,
        2
    )
FROM dwd_user_session;

-- 7. DWS：Session 行为分层汇总
-- 当前数据版本第5课得到 ProductRelated P75 = 38
DROP TABLE IF EXISTS dws_session_segment_summary;
CREATE TABLE dws_session_segment_summary AS
SELECT
    session_segment,
    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dwd_user_session), 2) AS session_share,
    ROUND(AVG(ProductRelated), 2) AS avg_product_views,
    ROUND(AVG(ProductRelated_Duration), 2) AS avg_product_duration,
    ROUND(AVG(BounceRates), 4) AS avg_bounce_rate,
    ROUND(AVG(ExitRates), 4) AS avg_exit_rate,
    ROUND(AVG(PageValues), 2) AS avg_page_value
FROM (
    SELECT
        *,
        CASE
            WHEN ProductRelated >= 38 AND is_Purchase = 1
                THEN 'High_Value'
            WHEN ProductRelated >= 38 AND is_Purchase = 0
                THEN 'High_Potential_Rule'
            WHEN ProductRelated < 38 AND is_Purchase = 1
                THEN 'Low_Activity_Purchase'
            ELSE 'Low_Activity_NonPurchase'
        END AS session_segment
    FROM dwd_user_session
) t
GROUP BY session_segment;
ALTER TABLE dws_session_segment_summary
ADD PRIMARY KEY (session_segment);

-- 8. ADS：核心 KPI
DROP TABLE IF EXISTS ads_core_kpi;
CREATE TABLE ads_core_kpi AS
SELECT
    COUNT(*) AS total_sessions,
    SUM(is_Purchase) AS purchase_sessions,
    COUNT(*) - SUM(is_Purchase) AS non_purchase_sessions,
    ROUND(SUM(is_Purchase) * 100.0 / COUNT(*), 2) AS conversion_rate,
    ROUND(AVG(ProductRelated), 2) AS avg_product_views,
    ROUND(AVG(ProductRelated_Duration), 2) AS avg_product_duration,
    ROUND(AVG(BounceRates), 4) AS avg_bounce_rate,
    ROUND(AVG(ExitRates), 4) AS avg_exit_rate,
    ROUND(AVG(PageValues), 2) AS avg_page_value
FROM dwd_user_session;

-- 9. ADS：月度 Dashboard
DROP TABLE IF EXISTS ads_monthly_dashboard;
CREATE TABLE ads_monthly_dashboard AS
SELECT
    Month_Num,
    Month,
    session_cnt,
    purchase_cnt,
    conversion_rate,
    avg_product_views,
    avg_product_duration,
    avg_bounce_rate,
    avg_exit_rate,
    avg_page_value
FROM dws_monthly_conversion;
ALTER TABLE ads_monthly_dashboard
ADD PRIMARY KEY (Month_Num);

-- 10. ADS：渠道优先级
DROP TABLE IF EXISTS ads_channel_priority;
CREATE TABLE ads_channel_priority AS
SELECT
    TrafficType,
    session_cnt,
    purchase_cnt,
    conversion_rate,
    purchase_share,
    avg_product_views,
    avg_product_duration,
    avg_page_value,
    DENSE_RANK() OVER (ORDER BY purchase_cnt DESC) AS purchase_volume_rank,
    DENSE_RANK() OVER (ORDER BY conversion_rate DESC) AS cvr_rank
FROM dws_traffic_type_conversion;
ALTER TABLE ads_channel_priority
ADD PRIMARY KEY (TrafficType);

-- 11. ADS：规则高潜 Session 明细
DROP TABLE IF EXISTS ads_high_potential_rule;
CREATE TABLE ads_high_potential_rule AS
SELECT
    session_id,
    Month_Num,
    Month,
    VisitorType,
    VisitorType_Name,
    TrafficType,
    is_Weekend,
    ProductRelated,
    ProductRelated_Duration,
    BounceRates,
    ExitRates,
    PageValues,
    TotalPage_Views,
    TotalPage_Duration,
    ProductView_Ratio,
    is_Purchase,
    'P75_ProductRelated>=38' AS rule_name
FROM dwd_user_session
WHERE ProductRelated >= 38
  AND is_Purchase = 0;
ALTER TABLE ads_high_potential_rule
ADD PRIMARY KEY (session_id);

-- 12. ADS：高潜群体画像
DROP TABLE IF EXISTS ads_high_potential_profile;
CREATE TABLE ads_high_potential_profile AS
SELECT
    COUNT(*) AS high_potential_sessions,
    ROUND(
        COUNT(*) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM dwd_user_session WHERE is_Purchase = 0), 0),
        2
    ) AS share_of_non_purchase,
    ROUND(AVG(ProductRelated), 2) AS avg_product_views,
    ROUND(AVG(ProductRelated_Duration), 2) AS avg_product_duration,
    ROUND(AVG(BounceRates), 4) AS avg_bounce_rate,
    ROUND(AVG(ExitRates), 4) AS avg_exit_rate,
    ROUND(AVG(PageValues), 2) AS avg_page_value
FROM ads_high_potential_rule;

-- 13. 最终表行数检查
SELECT 'dws_monthly_conversion' AS table_name, COUNT(*) AS row_cnt
FROM dws_monthly_conversion
UNION ALL
SELECT 'dws_visitor_type_conversion', COUNT(*)
FROM dws_visitor_type_conversion
UNION ALL
SELECT 'dws_traffic_type_conversion', COUNT(*)
FROM dws_traffic_type_conversion
UNION ALL
SELECT 'dws_product_depth_conversion', COUNT(*)
FROM dws_product_depth_conversion
UNION ALL
SELECT 'dws_product_duration_conversion', COUNT(*)
FROM dws_product_duration_conversion
UNION ALL
SELECT 'dws_proxy_funnel', COUNT(*)
FROM dws_proxy_funnel
UNION ALL
SELECT 'dws_session_segment_summary', COUNT(*)
FROM dws_session_segment_summary
UNION ALL
SELECT 'ads_core_kpi', COUNT(*)
FROM ads_core_kpi
UNION ALL
SELECT 'ads_monthly_dashboard', COUNT(*)
FROM ads_monthly_dashboard
UNION ALL
SELECT 'ads_channel_priority', COUNT(*)
FROM ads_channel_priority
UNION ALL
SELECT 'ads_high_potential_rule', COUNT(*)
FROM ads_high_potential_rule
UNION ALL
SELECT 'ads_high_potential_profile', COUNT(*)
FROM ads_high_potential_profile;
