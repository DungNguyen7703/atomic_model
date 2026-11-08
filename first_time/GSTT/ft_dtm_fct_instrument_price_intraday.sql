-- [FIRST-TIME] ft_dtm_fct_instrument_price_intraday: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_instrument_price_intraday (config ft_target='fct_instrument_price_intraday', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_instrument_price_intraday
* Program name: Dtm Fct Instrument Price Intraday
* Created by: tuan.nguyenvanb
* Created date: 2026-10-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-06		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_instrument_price_intraday.csv, GSTT
*                                       Nhom 34, LLD v4.33-v4.36] Fact nen PHUT theo do min ca ma CK VA
*                                       chi so: 1 dong / Instrument Code / Trading Timestamp. Nguon Atomic
*                                       market_price_snapshot (MDDS JAD_tvhistory1m). THAY dtm_fct_security_
*                                       trading_intraday (LLD da bai bo thuc the cu - model cu GIU NGUYEN
*                                       trong repo, chua xoa, cho den khi duoc xac nhan).
*                                       Doi so voi model cu: them instrument_code (mã CK hoac chi so),
*                                       open/high/low/close_price_at_time -> open/high/low/close_price,
*                                       them vol (KLGD phat sinh rieng tung phut), cdr_dt_dim_id ->
*                                       trade_dt_dim_id. cumulative_vol_at_time giu nguyen (running sum).
*                                       [LUU Y] LLD ghi src_stm_code 'MDDS_JAD_TRADINGVIEWHISTORY1MIN';
*                                       atomic atm_market_price_snapshot dung 'MDDS_JAD_TVHISTORY1MIN'
*                                       cho nen phut - code dung gia tri thuc te cua atomic (giong model
*                                       cu).
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
        processing_time,
        open_price,
        high_price,
        low_price,
        close_price,
        vol
    FROM {{ ft_ref('ft_atm_market_price_snapshot') }}
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        -- [BACKFILL-UAT-ORIG] AND src_stm_code = 'MDDS_JAD_TVHISTORY1MIN'
    WHERE src_stm_code = 'MDDS_JAD_TVHISTORY1MIN'   -- [BACKFILL-UAT-NEW]
),

ma_pr_sn_cum AS (
    SELECT
        symbol,
        trading_dt,
        processing_time,
        open_price,
        high_price,
        low_price,
        close_price,
        vol,
        -- vol la KLGD phat sinh rieng trong phut (khong luy ke) - running-sum theo dung ban chat
        -- luy ke cua cumulative_vol_at_time (LLD).
        SUM(vol) OVER (PARTITION BY symbol, trading_dt ORDER BY processing_time) AS cumulative_vol_at_time
    FROM ma_pr_sn
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
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string)                                        AS security_trading_snpst_dim_id,
    CAST(date_format(ma_pr_sn_cum.trading_dt, 'yyyyMMdd') AS string)                                  AS trade_dt_dim_id,
    CAST(ma_pr_sn_cum.symbol AS string)                                                               AS instrument_code,
    to_timestamp(concat(date_format(ma_pr_sn_cum.trading_dt, 'yyyy-MM-dd'), ' ', ma_pr_sn_cum.processing_time)) AS trading_tms,
    CAST(ma_pr_sn_cum.open_price AS decimal(23,2))                                                    AS open_price,
    CAST(ma_pr_sn_cum.high_price AS decimal(23,2))                                                    AS high_price,
    CAST(ma_pr_sn_cum.low_price AS decimal(23,2))                                                     AS low_price,
    CAST(ma_pr_sn_cum.close_price AS decimal(23,2))                                                   AS close_price,
    CAST(ma_pr_sn_cum.vol AS int)                                                                     AS vol,
    CAST(ma_pr_sn_cum.cumulative_vol_at_time AS int)                                                  AS cumulative_vol_at_time
FROM ma_pr_sn_cum
LEFT JOIN se_tr_sn_di
    ON  se_tr_sn_di.symbol = ma_pr_sn_cum.symbol
    AND se_tr_sn_di.ds_snpst_dt = CAST(ma_pr_sn_cum.trading_dt AS date)   -- [FIRST-TIME 2026-10-18]
