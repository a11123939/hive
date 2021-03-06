SET hive.vectorized.execution.enabled=true;
set hive.fetch.task.conversion=minimal;

DROP TABLE IF EXISTS DECIMAL_UDF_txt;
DROP TABLE IF EXISTS DECIMAL_UDF;

CREATE TABLE DECIMAL_UDF_txt (key decimal(20,10), value int)
ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ' '
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '../../data/files/kv7.txt' INTO TABLE DECIMAL_UDF_txt;

CREATE TABLE DECIMAL_UDF (key decimal(20,10), value int)
STORED AS ORC;

INSERT OVERWRITE TABLE DECIMAL_UDF SELECT * FROM DECIMAL_UDF_txt;

-- addition
EXPLAIN SELECT key + key FROM DECIMAL_UDF;
SELECT key + key FROM DECIMAL_UDF;

EXPLAIN SELECT key + value FROM DECIMAL_UDF;
SELECT key + value FROM DECIMAL_UDF;

EXPLAIN SELECT key + (value/2) FROM DECIMAL_UDF;
SELECT key + (value/2) FROM DECIMAL_UDF;

EXPLAIN SELECT key + '1.0' FROM DECIMAL_UDF;
SELECT key + '1.0' FROM DECIMAL_UDF;

-- substraction
EXPLAIN SELECT key - key FROM DECIMAL_UDF;
SELECT key - key FROM DECIMAL_UDF;

EXPLAIN SELECT key - value FROM DECIMAL_UDF;
SELECT key - value FROM DECIMAL_UDF;

EXPLAIN SELECT key - (value/2) FROM DECIMAL_UDF;
SELECT key - (value/2) FROM DECIMAL_UDF;

EXPLAIN SELECT key - '1.0' FROM DECIMAL_UDF;
SELECT key - '1.0' FROM DECIMAL_UDF;

-- multiplication
EXPLAIN SELECT key * key FROM DECIMAL_UDF;
SELECT key * key FROM DECIMAL_UDF;

EXPLAIN SELECT key, value FROM DECIMAL_UDF where key * value > 0;
SELECT key, value FROM DECIMAL_UDF where key * value > 0;

EXPLAIN SELECT key * value FROM DECIMAL_UDF;
SELECT key * value FROM DECIMAL_UDF;

EXPLAIN SELECT key * (value/2) FROM DECIMAL_UDF;
SELECT key * (value/2) FROM DECIMAL_UDF;

EXPLAIN SELECT key * '2.0' FROM DECIMAL_UDF;
SELECT key * '2.0' FROM DECIMAL_UDF;

-- division
EXPLAIN SELECT key / 0 FROM DECIMAL_UDF limit 1;
SELECT key / 0 FROM DECIMAL_UDF limit 1;

EXPLAIN SELECT key / NULL FROM DECIMAL_UDF limit 1;
SELECT key / NULL FROM DECIMAL_UDF limit 1;

EXPLAIN SELECT key / key FROM DECIMAL_UDF WHERE key is not null and key <> 0;
SELECT key / key FROM DECIMAL_UDF WHERE key is not null and key <> 0;

EXPLAIN SELECT key / value FROM DECIMAL_UDF WHERE value is not null and value <> 0;
SELECT key / value FROM DECIMAL_UDF WHERE value is not null and value <> 0;

EXPLAIN SELECT key / (value/2) FROM DECIMAL_UDF  WHERE value is not null and value <> 0;
SELECT key / (value/2) FROM DECIMAL_UDF  WHERE value is not null and value <> 0;

EXPLAIN SELECT 1 + (key / '2.0') FROM DECIMAL_UDF;
SELECT 1 + (key / '2.0') FROM DECIMAL_UDF;

-- abs
EXPLAIN SELECT abs(key) FROM DECIMAL_UDF;
SELECT abs(key) FROM DECIMAL_UDF;

-- avg
EXPLAIN SELECT value, sum(key) / count(key), avg(key), sum(key) FROM DECIMAL_UDF GROUP BY value ORDER BY value;
SELECT value, sum(key) / count(key), avg(key), sum(key) FROM DECIMAL_UDF GROUP BY value ORDER BY value;

-- negative
EXPLAIN SELECT -key FROM DECIMAL_UDF;
SELECT -key FROM DECIMAL_UDF;

-- positive
EXPLAIN SELECT +key FROM DECIMAL_UDF;
SELECT +key FROM DECIMAL_UDF;

-- ceiling
EXPlAIN SELECT CEIL(key) FROM DECIMAL_UDF;
SELECT CEIL(key) FROM DECIMAL_UDF;

-- floor
EXPLAIN SELECT FLOOR(key) FROM DECIMAL_UDF;
SELECT FLOOR(key) FROM DECIMAL_UDF;

-- round
EXPLAIN SELECT ROUND(key, 2) FROM DECIMAL_UDF;
SELECT ROUND(key, 2) FROM DECIMAL_UDF;

-- power
EXPLAIN SELECT POWER(key, 2) FROM DECIMAL_UDF;
SELECT POWER(key, 2) FROM DECIMAL_UDF;

-- modulo
EXPLAIN SELECT (key + 1) % (key / 2) FROM DECIMAL_UDF;
SELECT (key + 1) % (key / 2) FROM DECIMAL_UDF;

-- stddev, var
EXPLAIN SELECT value, stddev(key), variance(key) FROM DECIMAL_UDF GROUP BY value;
SELECT value, stddev(key), variance(key) FROM DECIMAL_UDF GROUP BY value;

-- stddev_samp, var_samp
EXPLAIN SELECT value, stddev_samp(key), var_samp(key) FROM DECIMAL_UDF GROUP BY value;
SELECT value, stddev_samp(key), var_samp(key) FROM DECIMAL_UDF GROUP BY value;

-- histogram
EXPLAIN SELECT histogram_numeric(key, 3) FROM DECIMAL_UDF; 
SELECT histogram_numeric(key, 3) FROM DECIMAL_UDF; 

-- min
EXPLAIN SELECT MIN(key) FROM DECIMAL_UDF;
SELECT MIN(key) FROM DECIMAL_UDF;

-- max
EXPLAIN SELECT MAX(key) FROM DECIMAL_UDF;
SELECT MAX(key) FROM DECIMAL_UDF;

-- count
EXPLAIN SELECT COUNT(key) FROM DECIMAL_UDF;
SELECT COUNT(key) FROM DECIMAL_UDF;

DROP TABLE IF EXISTS DECIMAL_UDF_txt;
DROP TABLE IF EXISTS DECIMAL_UDF;

