#总数据量
SELECT COUNT(*) AS total_rows
FROM ods_online_shoppers;

#购买数量
SELECT
    revenue,
    COUNT(*) AS session_cnt
FROM ods_online_shoppers
GROUP BY revenue;

#用户类型分布
SELECT
    VisitorType,
    COUNT(*) AS session_cnt
FROM ods_online_shoppers
GROUP BY visitortype
ORDER BY session_cnt DESC;

#月份分布
SELECT
    month,
    COUNT(*) AS session_cnt
FROM ods_online_shoppers
GROUP BY month
ORDER BY session_cnt DESC;

#流量渠道分布
SELECT
    TrafficType,
    COUNT(*) AS session_cnt
FROM ods_online_shoppers
GROUP BY TrafficType
ORDER BY session_cnt DESC;

#检查数值字段的最小值和最大值
SELECT
    MIN(Administrative) AS min_Administrative,
    MAX(Administrative) AS max_Administrative,

    MIN(Informational) AS min_Informational,
    MAX(Informational) AS max_Informational,

    MIN(ProductRelated) AS min_ProductRelated,
    MAX(ProductRelated) AS max_ProductRelated
FROM ods_online_shoppers;

#检查停留时间
SELECT
    MIN(Administrative_Duration) AS min_Admin_Duration,
    MAX(Administrative_Duration) AS max_Admin_Duration,

    MIN(Informational_Duration) AS min_Info_Duration,
    MAX(Informational_Duration) AS max_Info_Duration,

    MIN(ProductRelated_duration) AS min_Product_Duration,
    MAX(ProductRelated_duration) AS max_Product_Duration
FROM ods_online_shoppers;

#检查比例类字段
SELECT
    MIN(BounceRates) AS min_BounceRate,
    MAX(BounceRates) AS max_BounceRate,
    MIN(ExitRates) AS min_ExitRate,
    MAX(ExitRates) AS max_ExitRate
FROM ods_online_shoppers;

#检查分类字段
SELECT DISTINCT month
FROM ods_online_shoppers;

#检查VisitorType
SELECT DISTINCT VisitorType
FROM ods_online_shoppers;

#检查Weekend和Revenue
SELECT DISTINCT Weekend
FROM ods_online_shoppers;

SELECT DISTINCT Revenue
FROM ods_online_shoppers;