-- ────────────────────────────────────────────────────────────
-- Model : cdr_dt_flat
-- Type  : DIMENSION (khong phai FACT "_snpst")
-- ────────────────────────────────────────────────────────────
-- Ghi chu (2026-09-19, tuan.nguyenvanb): Day la danh muc TINH (Calendar
-- Date), khac ban chat voi cac Fact "_snpst" khac. KHONG filter theo
-- etl_date - moi lan chay doc lai TOAN BO dai ngay tu dtm_cdr_dt_dim
-- (nguon da sinh san ca ngay qua khu lan tuong lai).
--
-- 2026-10-09 (LLD): is_trading_date LAY THANG tu cot is_trading_date cua dtm_cdr_dt_dim
-- (Y neu ngay co ban ghi o CA HAI Market Index Snapshot va Security Trading Snapshot; ngay
-- tuong lai chua toi la 'N'). Truoc day tinh o day tu dtm_fct_market_index_snpst (rule cu 2026-09-05).
-- 2026-10-12 (LLD v4.46, O_GSTT_62): rule doi lan 2 - Y neu ngay co ban ghi o IT NHAT MOT trong 4 nguon
-- (UNION market_index_snapshot, security_trading_snapshot, securities_trade nhanh TRADE_BOOK_HOSE/HNX). Logic nam o
-- dtm_cdr_dt_dim; model flat nay KHONG doi (chi sao chep cot).
--
-- 2026-09-19: DA THU 4 phuong an truoc khi chot, deu vuong gioi han cua
-- connector Spark -> catalog 'clickhouse' (com.clickhouse.spark):
--   1) incremental_rebase/merge (MERGE INTO): loi UNRESOLVED_COLUMN -
--      MergeIntoTable khong ho tro nguon USING co chua JOIN tren catalog nay.
--   2) materialized: table (dbt-spark native): loi TABLE_ALREADY_EXISTS -
--      ClickHouseCatalog.createTable() khong ho tro REPLACE TABLE.
--   3) append KHONG khai bao partition_by: loi "does not support dynamic
--      overwrite in batch mode".
--   4) append + partition_by=['year'] (bang vat ly da xac nhan co
--      PARTITION BY year that su qua SHOW CREATE TABLE): VAN loi y het
--      "does not support dynamic overwrite in batch mode" - xac nhan bang
--      du lieu that day la GIOI HAN CUA CONNECTOR (khong ho tro
--      OverwritePartitionsDynamic cho bat ky bang ClickHouse nao), khong
--      phai do thieu partition.
-- => Chot: materialized=incremental (dbt-spark native, KHONG dung macro
-- incremental_rebase), incremental_strategy=append => compile ra INSERT
-- INTO thuan (khong OVERWRITE/MERGE). Dua vao co che dedup nen tu nhien
-- cua ENGINE=ReplacingMergeTree theo ORDER BY (cdr_dt, cdr_dt_dim_id).
-- QUAN TRONG: moi truy van xuong bang nay o tang sau (dashboard/BI) BAT
-- BUOC dung FINAL (SELECT ... FROM cdr_dt_flat FINAL) de tranh doc phai
-- ban ghi cu chua duoc merge nen.

SELECT
    cal.cdr_dt_dim_id,
    cal.cdr_dt,
    cal.year,
    cal.quarter,
    cal.month,
    cal.day_of_week,
    cal.is_weekend,
    cal.holiday_flag,
    cal.is_trading_date                     AS is_trading_date
FROM {{ ref('dtm_cdr_dt_dim') }} cal
