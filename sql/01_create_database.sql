CREATE DATABASE IF NOT EXISTS ecommerce_analysis
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE ecommerce_analysis;

SHOW DATABASES;

SELECT COUNT(*) AS total_rows
FROM ods_online_shoppers;

SELECT *
FROM ods_online_shoppers
LIMIT 20;
