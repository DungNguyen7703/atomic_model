/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_security_trading_daily
* Program name: Dtm Fct Security Trading Daily
* Created by: tuan.nguyenvanb
* Created date: 2026-09-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-30		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_security_trading_daily.csv,
*                                       O_GSTT_51, GSTT Nhom 34] Nen gia OHLCV theo NGAY
*                                       (khung thoi gian loc tu 1 thang tro len) - nguon
*                                       atm_market_price_snapshot, src_stm_code =
*                                       'MDDS_JAD_TRADINGVIEWHISTORY1DAY'. Grain 1 dong / ma CK
*                                       / ngay giao dich.
*--------------------------------------------------------------------*
*/

WITH ma_pr_sn AS (
    SELECT
        symbol,
        trading_dt,
        open_price,
        high_price,
        low_price,
        close_price,
        vol
    FROM {{ ref('atm_market_price_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_TRADINGVIEWHISTORY1DAY'
),

se_tr_sn_di AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol
    FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string)        AS security_trading_snpst_dim_id,
    CAST(date_format(ma_pr_sn.trading_dt, 'yyyyMMdd') AS string)      AS trade_dt_dim_id,
    CAST(ma_pr_sn.open_price AS decimal(23,2))                        AS daily_open_price,
    CAST(ma_pr_sn.high_price AS decimal(23,2))                        AS daily_high_price,
    CAST(ma_pr_sn.low_price AS decimal(23,2))                         AS daily_low_price,
    CAST(ma_pr_sn.close_price AS decimal(23,2))                       AS daily_close_price,
    CAST(ma_pr_sn.vol AS int)                                         AS daily_vol
FROM ma_pr_sn
LEFT JOIN se_tr_sn_di
    ON  se_tr_sn_di.symbol = ma_pr_sn.symbol
