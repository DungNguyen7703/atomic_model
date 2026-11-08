-- [FIRST-TIME] ft_dtm_fct_order_size_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_order_size_snpst (config ft_target='fct_order_size_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_order_size_snpst
* Program name: Fact Order Size Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_order_size_snpst:
*									- doc atomic qua ft_ref (ft_atm_security_trading_snapshot / ft_atm_securities_trade), BO loc theo etl_date de nap toan bo lich su 1 lan.
*									- append: ds_snpst_dt = trade_dt cua tung dong (daily snapshot: ds_snpst_dt = etl_date = ngay giao dich), dat CUOI SELECT.
*									- Dedupe ban tin cuoi ngay da theo (ticker_symbol, ds_snpst_dt); khoa phu join_key (symbol / isin_code) noi equi-join theo ngay
*									  (src_stm_code, join_key, trading_dt = trade_dt) - khong dung OR -> khong nested loop.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH sts_raw AS (
    SELECT
        ticker_symbol AS symbol
        , isin_code
        , ds_snpst_dt AS trading_dt
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- A17: HOSE noi theo symbol, HNX noi theo isin_code -> khoa phu join_key (equi-join, khong dung OR)
sts_key AS (
    SELECT
        trading_dt
        , symbol
        , CAST('ORDERTRADE_TRADE_BOOK_HOSE' AS string) AS src_stm_code
        , symbol                                       AS join_key
    FROM sts_raw
    WHERE rn = 1
    UNION ALL
    SELECT
        trading_dt
        , symbol
        , CAST('ORDERTRADE_TRADE_BOOK_HNX' AS string)  AS src_stm_code
        , isin_code                                    AS join_key
    FROM sts_raw
    WHERE rn = 1
        AND isin_code IS NOT NULL
),

se_tr AS (
    SELECT
        trade_dt
        , src_stm_code
        , security_symbol_code
        , execution_val
        , execution_vol
    FROM {{ ft_ref('ft_atm_securities_trade') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE market_id_code IN ('STK','STX','UPX')
),

agg AS (
    SELECT
        se_tr.trade_dt                                                          AS trading_dt
        , COALESCE(sts_key.symbol, se_tr.security_symbol_code)                  AS symbol
        , CASE
            WHEN se_tr.execution_val >= 1000000000 THEN 'GTGD >= 1 ty'
            ELSE 'GTGD < 1 ty'
          END                                                                   AS order_size_band
        , SUM(se_tr.execution_val)                                              AS total_trading_val_matched
        , SUM(se_tr.execution_vol)                                              AS total_trading_vol_matched
    FROM se_tr
    LEFT JOIN sts_key
        ON sts_key.src_stm_code = se_tr.src_stm_code
        AND sts_key.join_key = se_tr.security_symbol_code
        AND sts_key.trading_dt = se_tr.trade_dt
    GROUP BY
        se_tr.trade_dt
        , COALESCE(sts_key.symbol, se_tr.security_symbol_code)
        , CASE
            WHEN se_tr.execution_val >= 1000000000 THEN 'GTGD >= 1 ty'
            ELSE 'GTGD < 1 ty'
          END
)

SELECT
    CAST(date_format(agg.trading_dt, 'yyyyMMdd') AS string)        AS snpst_dt_dim_id,
    CAST(agg.symbol AS string)                                     AS security_symbol_code,
    CAST(agg.total_trading_val_matched AS decimal(23,2))           AS total_trading_val_matched,
    CAST(agg.order_size_band AS string)                            AS order_size_band,
    CAST(agg.total_trading_vol_matched AS decimal(23,2))           AS total_trading_vol_matched,
    CAST(agg.trading_dt AS date)                                   AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = etl_date)
FROM agg
