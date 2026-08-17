#整体经营指标
SELECT
	COUNT(*) as total_session,
	SUM(is_Purchase) as purchase_session,
    ROUND( SUM(is_Purchase)*100 / COUNT(*), 2 ) as conversion_rate
FROM dwd_user_session;

#月度经营趋势
SELECT
    month_num,
    month,
    COUNT(*) AS session_cnt,
    SUM(is_purchase) AS purchase_cnt,
    ROUND(
        SUM(is_purchase) * 100.0 / COUNT(*), 2
    ) AS conversion_rate
FROM dwd_user_session
GROUP BY month_num, month
ORDER BY conversion_rate ASC;

#新用户 vs 老用户
SELECT
    VisitorType_Name,
    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(
        SUM(is_Purchase) * 100.0 / COUNT(*),
        2
    ) AS conversion_rate
FROM dwd_user_session
GROUP BY VisitorType_Name
ORDER BY conversion_rate DESC;

#看ProductRelated分布
SELECT
    MIN(ProductRelated) AS min_views,
    MAX(ProductRelated) AS max_views,
    ROUND(AVG(ProductRelated), 2) AS avg_views
FROM dwd_user_session;
#看分布
SELECT
    ProductRelated,
    COUNT(*) AS session_cnt
FROM dwd_user_session
GROUP BY ProductRelated
ORDER BY ProductRelated;

#使用CASE WHEN做用户行为分层
SELECT
    CASE
        WHEN ProductRelated <= 5 THEN '01_0-5'
        WHEN ProductRelated <= 10 THEN '02_6-10'
        WHEN ProductRelated <= 20 THEN '03_11-20'
        WHEN ProductRelated <= 50 THEN '04_21-50'
        ELSE '05_50+'
    END AS product_view_group,

    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(
        SUM(is_Purchase) * 100.0 / COUNT(*),
        2
    ) AS conversion_rate
FROM dwd_user_session
GROUP BY
    CASE
        WHEN ProductRelated <= 5 THEN '01_0-5'
        WHEN ProductRelated <= 10 THEN '02_6-10'
        WHEN ProductRelated <= 20 THEN '03_11-20'
        WHEN ProductRelated <= 50 THEN '04_21-50'
        ELSE '05_50+'
    END
ORDER BY product_view_group;

#商品停留时间分析
SELECT
    CASE
        WHEN ProductRelated_Duration < 120
            THEN '01_0-2min'
        WHEN ProductRelated_Duration < 300
            THEN '02_2-5min'
        WHEN ProductRelated_Duration < 600
            THEN '03_5-10min'
        WHEN ProductRelated_Duration < 1200
            THEN '04_10-20min'
        ELSE '05_20min+'
    END AS duration_group,
    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(
        SUM(is_Purchase) * 100.0 / COUNT(*),
        2
    ) AS conversion_rate
FROM dwd_user_session
GROUP BY
    CASE
        WHEN ProductRelated_Duration < 120
            THEN '01_0-2min'
        WHEN ProductRelated_Duration < 300
            THEN '02_2-5min'
        WHEN ProductRelated_Duration < 600
            THEN '03_5-10min'
        WHEN ProductRelated_Duration < 1200
            THEN '04_10-20min'
        ELSE '05_20min+'
    END
ORDER BY duration_group;

#不同流量渠道带来的Session质量是否一样
SELECT
    TrafficType,
    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(
        SUM(is_Purchase) * 100.0 / COUNT(*),
        2
    ) AS conversion_rate
FROM dwd_user_session
GROUP BY TrafficType
HAVING COUNT(*) >= 100
ORDER BY conversion_rate DESC;

#漏斗
SELECT
    COUNT(*) AS total_sessions,
    SUM(
        CASE
            WHEN ProductRelated > 0 THEN 1
            ELSE 0
        END
    ) AS product_view_sessions,
    SUM(
        CASE
            WHEN ProductRelated >= 10 THEN 1
            ELSE 0
        END
    ) AS deep_view_sessions,
    SUM(is_Purchase) AS purchase_sessions
FROM dwd_user_session;

#计算每一步转化率
SELECT
    COUNT(*) AS total_sessions,
    SUM(ProductRelated > 0) AS product_view_sessions,
    SUM(ProductRelated >= 10) AS deep_view_sessions,
    SUM(is_Purchase) AS purchase_sessions,
    ROUND(
        SUM(ProductRelated > 0) * 100.0
        / COUNT(*),
        2
    ) AS visit_to_product_rate,
    ROUND(
        SUM(ProductRelated >= 10) * 100.0
        / NULLIF(SUM(ProductRelated > 0), 0),
        2
    ) AS product_to_deep_rate,
    ROUND(
        SUM(is_Purchase) * 100.0
        / NULLIF(SUM(ProductRelated >= 10), 0),
        2
    ) AS deep_to_purchase_rate
FROM dwd_user_session;

#非常有价值的人：高浏览、未购买Session
SELECT
    session_id,
    ProductRelated,
    ProductRelated_Duration,
    BounceRates,
    ExitRates,
    PageValues,
    TrafficType,
    VisitorType_Name,
    month
FROM dwd_user_session
WHERE ProductRelated >= 30
  AND is_purchase = 0
ORDER BY ProductRelated DESC;