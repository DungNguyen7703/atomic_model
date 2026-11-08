-- [FIRST-TIME] ft_dtm_fct_cap_grp_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_cap_grp_snpst (config ft_target='fct_cap_grp_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_cap_grp_snpst
* Program name: Fact Cap Group Snapshot (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[FIRST-TIME PTTT] Ban khoi tao tu dtm_fct_cap_grp_snpst:
*									- doc atomic qua ft_ref (ft_atm_security_trading_snapshot / ft_atm_listed_share_information), BO loc theo etl_date de nap toan bo lich su 1 lan.
*									- append: ds_snpst_dt = trading_dt cua tung dong (daily snapshot: ds_snpst_dt = etl_date = ngay giao dich), dat CUOI SELECT.
*									- Dedupe ban tin cuoi ngay theo (ticker_symbol, ds_snpst_dt); KL luu hanh VSDC noi DUNG NGAY (ticker_symbol, transaction_dt = trading_dt)
*									  va dedupe theo (ticker_symbol, transaction_dt); mau so liquidity_share_ratio gom theo trading_dt.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH se_tr_snpst_raw AS (

    SELECT
        ds_snpst_dt AS trading_dt
        , ticker_symbol AS symbol
        , close_price
        , total_trading_val
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE floor_code IN ('02','04','10')

),

se_tr_snpst AS (

    SELECT trading_dt, symbol, close_price, total_trading_val
    FROM se_tr_snpst_raw
    WHERE rn = 1

),

listed_share_all AS (

    SELECT
        ticker_symbol
        , transaction_dt
        , outstanding_share_quantity
        , ROW_NUMBER() OVER (PARTITION BY ticker_symbol, transaction_dt ORDER BY ds_snpst_dt DESC) AS rn
    FROM {{ ft_ref('ft_atm_listed_share_information') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE src_stm_code = 'VSDC_OUTSTANDING_SHARES'
    -- [BACKFILL-UAT-ORIG]     AND transaction_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')

),

listed_share_latest AS (

    SELECT
        ticker_symbol
        , transaction_dt
        , outstanding_share_quantity
    FROM listed_share_all
    WHERE rn = 1

),

cap_classified AS (

    SELECT
        se_tr_snpst.trading_dt
        , se_tr_snpst.symbol
        , se_tr_snpst.total_trading_val
        , CASE
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) >= 100000000000
             AND (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) <  1000000000000  THEN 'Smallcap'
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) >= 1000000000000
             AND (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) <= 10000000000000 THEN 'Midcap'
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) >  10000000000000 THEN 'Largecap'
            ELSE NULL
          END AS cap_group_code
    FROM se_tr_snpst
    INNER JOIN listed_share_latest
        ON listed_share_latest.ticker_symbol = se_tr_snpst.symbol
        AND listed_share_latest.transaction_dt = se_tr_snpst.trading_dt   -- [BACKFILL-UAT-NEW] noi theo NGAY (daily chi co 1 ngay)

),

cap_group_agg AS (

    SELECT
        cap_classified.trading_dt
        , cap_classified.cap_group_code
        , SUM(cap_classified.total_trading_val) AS total_trading_val
    FROM cap_classified
    WHERE cap_classified.cap_group_code IS NOT NULL
    GROUP BY
        cap_classified.trading_dt
        , cap_classified.cap_group_code

),

market_total AS (

    SELECT
        se_tr_snpst.trading_dt
        , SUM(se_tr_snpst.total_trading_val) AS market_total_trading_val
    FROM se_tr_snpst
    GROUP BY se_tr_snpst.trading_dt

)

SELECT
    CAST(date_format(cap_group_agg.trading_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(cap_group_agg.cap_group_code AS string)                      AS cap_group_code,
    CAST(cap_group_agg.total_trading_val AS decimal(23,2))            AS total_trading_val,
    CAST(
        cap_group_agg.total_trading_val
        / NULLIF(market_total.market_total_trading_val, 0) * 100
    AS decimal(5,2))                                                  AS liquidity_share_ratio,
    CAST(cap_group_agg.trading_dt AS date)                            AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = etl_date)
FROM cap_group_agg
LEFT JOIN market_total
    ON market_total.trading_dt = cap_group_agg.trading_dt
