#DWD数据量
SELECT COUNT(*) AS total_rows
FROM dwd_user_session;

#session是否唯一
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT session_id) AS distinct_session_id
FROM dwd_user_session;

#页面访问次数不能为负数
SELECT COUNT(*) AS invalid_rows
FROM dwd_user_session
WHERE Administrative < 0
   OR Informational < 0
   OR ProductRelated < 0;
   
#Duration不能为负
SELECT COUNT(*) AS invalid_rows
FROM dwd_user_session
WHERE Administrative_Duration < 0
   OR Informational_Duration < 0
   OR ProductRelated_Duration < 0;
   
#比例是否越界
SELECT COUNT(*) AS invalid_rows
FROM dwd_user_session
WHERE ProductView_Ratio < 0
   OR ProductView_Ratio > 1;
   
#Month是否存在无法识别的值
SELECT *
FROM dwd_user_session
WHERE Month_Num IS NULL;

#Q:新用户和老用户，谁的购买转化率更高？
SELECT
    VisitorType_Name,
    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(
        SUM(is_Purchase) / COUNT(*) * 100,
        2
    ) AS conversion_rate
FROM dwd_user_session
GROUP BY VisitorType_Name
ORDER BY conversion_rate DESC;

#Q:分析周末与工作日
SELECT
    CASE
        WHEN is_Weekend = 1 THEN '周末'
        ELSE '工作日'
    END AS day_type,
    COUNT(*) AS session_cnt,
    SUM(is_Purchase) AS purchase_cnt,
    ROUND(
        SUM(is_Purchase) / COUNT(*) * 100,
        2
    ) AS conversion_rate
FROM dwd_user_session
GROUP BY is_Weekend
ORDER BY conversion_rate DESC;