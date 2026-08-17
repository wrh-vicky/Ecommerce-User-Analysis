USE ecommerce_analysis;

DROP TABLE IF EXISTS dwd_user_session;


SELECT DISTINCT Weekend, Revenue
FROM ods_online_shoppers;

#创建DWD表
CREATE TABLE dwd_user_session (
    session_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    Administrative INT,
    Administrative_Duration DOUBLE,

    Informational INT,
    Informational_Duration DOUBLE,

    ProductRelated INT,
    ProductRelated_Duration DOUBLE,

    BounceRates DOUBLE,
    ExitRates DOUBLE,
    PageValues DOUBLE,

    SpecialDay DOUBLE,

    Month VARCHAR(20),
    Month_Num INT,

    OperatingSystems INT,
    Browser INT,
    Region INT,
    TrafficType INT,

    VisitorType VARCHAR(50),
    VisitorType_Name VARCHAR(20),

    Weekend BOOLEAN,
    is_Weekend TINYINT,

    Revenue BOOLEAN,
    is_Purchase TINYINT,

    TotalPage_Views INT,
    TotalPage_Duration DOUBLE,

    ProductView_Ratio DOUBLE
);

#正式进行ODS → DWD
INSERT INTO dwd_user_session (
    Administrative,
    Administrative_Duration,
    Informational,
    Informational_Duration,
    ProductRelated,
    ProductRelated_Duration,
    BounceRates,
    ExitRates,
    PageValues,
    SpecialDay,
    Month,
    Month_Num,
    OperatingSystems,
    Browser,
    Region,
    TrafficType,
    VisitorType,
    VisitorType_Name,
    Weekend,
    is_Weekend,
    Revenue,
    is_Purchase,
    TotalPage_Views,
    TotalPage_Duration,
    ProductView_Ratio
)
SELECT
    Administrative,
    Administrative_Duration,
    Informational,
    Informational_Duration,
    ProductRelated,
    ProductRelated_Duration,
    BounceRates,
    ExitRates,
    PageValues,
    SpecialDay,
    Month,

    CASE Month
        WHEN 'Jan'  THEN 1
        WHEN 'Feb'  THEN 2
        WHEN 'Mar'  THEN 3
        WHEN 'Apr'  THEN 4
        WHEN 'May'  THEN 5
        WHEN 'June' THEN 6
        WHEN 'Jul'  THEN 7
        WHEN 'Aug'  THEN 8
        WHEN 'Sep'  THEN 9
        WHEN 'Oct'  THEN 10
        WHEN 'Nov'  THEN 11
        WHEN 'Dec'  THEN 12
        ELSE NULL
    END AS Month_Num,

    OperatingSystems,
    Browser,
    Region,
    TrafficType,
    VisitorType,

    CASE VisitorType
        WHEN 'New_Visitor' THEN '新用户'
        WHEN 'Returning_Visitor' THEN '老用户'
        WHEN 'Other' THEN '其他'
        ELSE '未知'
    END AS VisitorType_Name,

    -- FALSE -> 0，TRUE -> 1
    CASE
        WHEN UPPER(TRIM(Weekend)) = 'TRUE' THEN 1
        ELSE 0
    END AS Weekend,

    CASE
        WHEN UPPER(TRIM(Weekend)) = 'TRUE' THEN 1
        ELSE 0
    END AS is_Weekend,

    -- FALSE -> 0，TRUE -> 1
    CASE
        WHEN UPPER(TRIM(Revenue)) = 'TRUE' THEN 1
        ELSE 0
    END AS Revenue,

    CASE
        WHEN UPPER(TRIM(Revenue)) = 'TRUE' THEN 1
        ELSE 0
    END AS is_Purchase,

    Administrative
        + Informational
        + ProductRelated
        AS TotalPage_Views,

    Administrative_Duration
        + Informational_Duration
        + ProductRelated_Duration
        AS TotalPage_Duration,

    CASE
        WHEN Administrative
             + Informational
             + ProductRelated = 0
        THEN 0
        ELSE
            ProductRelated * 1.0 /
            (
                Administrative
                + Informational
                + ProductRelated
            )
    END AS ProductView_Ratio

FROM ods_online_shoppers;

#检查是否1对1清洗
SELECT COUNT(*) AS dwd_rows
FROM dwd_user_session;

#检查DWD数据
SELECT *
FROM dwd_user_session
LIMIT 10;

#检查月份转换是否正确
SELECT
    month,
    month_num,
    COUNT(*) AS session_cnt
FROM dwd_user_session
GROUP BY month, month_num
ORDER BY month_num;

#检查用户类型转换
SELECT
    VisitorType,
    VisitorType_Name,
    COUNT(*) AS session_cnt
FROM dwd_user_session
GROUP BY VisitorType, VisitorType_Name;

#检查购买字段
SELECT
    Revenue,
    is_Purchase,
    COUNT(*) AS session_cnt
FROM dwd_user_session
GROUP BY Revenue, is_Purchase;

#检查衍生指标
SELECT
    session_id,
    Administrative,
    Informational,
    ProductRelated,
    TotalPage_Views,
    TotalPage_Duration,
    ProductView_Ratio
FROM dwd_user_session
LIMIT 20;

