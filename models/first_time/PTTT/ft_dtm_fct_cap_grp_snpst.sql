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
* 2026-11-08		tuan.nguyenvanb		Doi nguong nhom von hoa theo daily: Smallcap < 1.000 ty (BO can duoi 100 ty), Midcap [1.000 ty, 10.000 ty),
*									Largecap >= 10.000 ty. Khong doi cot/kieu nen khong can ALTER.
* 2026-11-10		nghia.le			Dong bo daily (code nguon BA): liquidity_share_ratio = GTGD nhom / tong GTGD cua chinh cac nhom theo ngay (tong 3 nhom = 100%); GTGD theo ma lay tu so lenh khop
*									(ft_atm_securities_trade: STK/STX/UPX, board G1,G2,G3,G4,G7,G8; HNX noi ma qua isin_code) thay cho total_trading_val cua snapshot.
*									Doi ten + doi cong thuc liquidity_share_ratio -> market_cap_share_ratio (ty trong VON HOA nhom, dong bo daily; can ALTER RENAME mart truoc). Von hoa nhom gom ca ma khong co giao dich (LEFT JOIN gtgd_theo_ma, GTGD = 0) nhu code nguon BA.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)

WITH se_tr_snpst_raw AS (

    SELECT
        ds_snpst_dt AS trading_dt
        , ticker_symbol AS symbol
        , isin_code
        , close_price
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY trading_time DESC, sequence DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}   -- [BACKFILL-UAT-NEW] ft_ref
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    WHERE floor_code IN ('02','04','10')

),

se_tr_snpst AS (

    SELECT trading_dt, symbol, isin_code, close_price
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

-- [2026-11-10, BA] GTGD theo ma CK lay tu SO LENH KHOP (trade book) nhu daily: STK (HOSE, ma = security_symbol_code) / STX, UPX (HNX, UPCOM - ma = ISIN -> doi
-- sang ma qua isin_code cua snapshot), board G1,G2,G3,G4,G7,G8; gom theo (ma, ngay) - first-time nap toan bo lich su nen KHONG loc etl_date.
trade_matched AS (

    SELECT
        trade_dt
        , security_symbol_code
        , market_id_code
        , execution_val
    FROM {{ ft_ref('ft_atm_securities_trade') }}   -- [BACKFILL-UAT-NEW] ft_ref
    WHERE market_id_code IN ('STK','STX','UPX')
        AND board_tp_code IN ('G1','G2','G3','G4','G7','G8')

),

ma_isin AS (

    SELECT DISTINCT
        trading_dt
        , isin_code
        , symbol
    FROM se_tr_snpst
    WHERE isin_code IS NOT NULL

),

trade_by_symbol AS (

    SELECT
        trade_matched.trade_dt AS trading_dt
        , CASE WHEN trade_matched.market_id_code = 'STK' THEN trade_matched.security_symbol_code ELSE ma_isin.symbol END AS symbol
        , trade_matched.execution_val
    FROM trade_matched
    LEFT JOIN ma_isin
        ON trade_matched.market_id_code IN ('STX','UPX')
        AND ma_isin.isin_code = trade_matched.security_symbol_code
        AND ma_isin.trading_dt = trade_matched.trade_dt
    WHERE trade_matched.market_id_code = 'STK' OR ma_isin.symbol IS NOT NULL

),

gtgd_theo_ma AS (

    SELECT
        trading_dt
        , symbol
        , SUM(execution_val) AS total_trading_val
    FROM trade_by_symbol
    GROUP BY
        trading_dt
        , symbol

),

cap_classified AS (

    SELECT
        se_tr_snpst.trading_dt
        , se_tr_snpst.symbol
        , COALESCE(gtgd_theo_ma.total_trading_val, 0) AS total_trading_val
        , (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) AS market_cap
        , CASE
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) <  1000000000000  THEN 'Smallcap'
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) >= 1000000000000
             AND (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) <  10000000000000 THEN 'Midcap'
            WHEN (se_tr_snpst.close_price * listed_share_latest.outstanding_share_quantity) >= 10000000000000 THEN 'Largecap'
            ELSE NULL
          END AS cap_group_code
    FROM se_tr_snpst
    INNER JOIN listed_share_latest
        ON listed_share_latest.ticker_symbol = se_tr_snpst.symbol
        AND listed_share_latest.transaction_dt = se_tr_snpst.trading_dt   -- [BACKFILL-UAT-NEW] noi theo NGAY (daily chi co 1 ngay)
    LEFT JOIN gtgd_theo_ma   -- [2026-11-10] LEFT (nhu BA): ma co von hoa nhung khong co GTGD van tinh von hoa vao nhom (GTGD = 0)
        ON gtgd_theo_ma.symbol = se_tr_snpst.symbol
        AND gtgd_theo_ma.trading_dt = se_tr_snpst.trading_dt

),

cap_group_agg AS (

    SELECT
        cap_classified.trading_dt
        , cap_classified.cap_group_code
        , SUM(cap_classified.total_trading_val) AS total_trading_val
        , SUM(cap_classified.market_cap) AS total_market_cap
    FROM cap_classified
    WHERE cap_classified.cap_group_code IS NOT NULL
    GROUP BY
        cap_classified.trading_dt
        , cap_classified.cap_group_code

)

SELECT
    CAST(date_format(cap_group_agg.trading_dt, 'yyyyMMdd') AS string) AS snpst_dt_dim_id,
    CAST(cap_group_agg.cap_group_code AS string)                      AS cap_group_code,
    CAST(cap_group_agg.total_trading_val AS decimal(23,2))            AS total_trading_val,
    CAST(
        cap_group_agg.total_market_cap
        / NULLIF(SUM(cap_group_agg.total_market_cap) OVER (PARTITION BY cap_group_agg.trading_dt), 0) * 100
    AS decimal(5,2))                                                  AS market_cap_share_ratio,
    CAST(cap_group_agg.trading_dt AS date)                            AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = etl_date)
FROM cap_group_agg
