-- [FIRST-TIME] ft_dtm_fct_security_trading_daily: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_security_trading_daily (config ft_target='fct_security_trading_daily', macro macros/first_time).
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
* 2026-10-08		tuan.nguyenvanb		[BACKFILL-UAT-NEW] TAM THOI: doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc duoc giu o dang comment BACKFILL-UAT-ORIG. Chuyen che do daily bang dbt/first_time_mode.py [BACKFILL-UAT-NEW]
*                                       de tra ve nguyen ban sau khi chay xong du lieu 1 nam. [BACKFILL-UAT-NEW]
* 2026-10-18		tuan.nguyenvanb		[FIX dim_id NULL o ma INACTIVE tai dim MAIN] noi dim security_trading_snpst_dim bang _hstr theo NGAY (ds_snpst_dt = ngay giao dich) thay vi MAIN ACTIVE. Khong doi cot.
*--------------------------------------------------------------------*
*/

-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] TAM THOI chay MOT LUOT nhieu ngay (1 nam) cho UAT: bo loc etl_date, tra cuu theo tung ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
WITH ma_pr_sn AS (
    SELECT
        symbol,
        trading_dt,
        open_price,
        high_price,
        low_price,
        close_price,
        vol
    FROM {{ ft_ref('ft_atm_market_price_snapshot') }}
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND src_stm_code = 'MDDS_JAD_TRADINGVIEWHISTORY1DAY'
    WHERE src_stm_code = 'MDDS_JAD_TRADINGVIEWHISTORY1DAY'   -- [BACKFILL-UAT-NEW]
),

se_tr_sn_di AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol,
        ds_snpst_dt
    FROM {{ ft_ref('ft_dtm_security_trading_snpst_dim') }}_hstr   -- [FIRST-TIME 2026-10-18] doc _hstr theo NGAY, khong doc MAIN
    WHERE ds_rcrd_st = 'ACTIVE'
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
    AND se_tr_sn_di.ds_snpst_dt = CAST(ma_pr_sn.trading_dt AS date)   -- [FIRST-TIME 2026-10-18]
