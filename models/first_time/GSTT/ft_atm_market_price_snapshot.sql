-- [FIRST-TIME] ft_atm_market_price_snapshot: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_market_price_snapshot (config ft_target='market_price_snapshot', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_market_price_snapshot
* Program name: Atomic Market Price Snapshot
* Created by: tuan.nguyenvanb
* Created date: 2026-09-09
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-09		tuan.nguyenvanb		Tao moi theo LLD DTM_GSTT_fct_security_trading_intraday
*                                       (sua 2026-09-07) - grain 1 dong/ma CK/ngay/phut
*                                       (nen 1-phut), nguon MDDS.JAD_TVHISTORY1M,
*                                       src_stm_code = MDDS_JAD_TRADINGVIEWHISTORY1MIN.
*                                       "vol" la KLGD PHAT SINH RIENG trong tung phut,
*                                       KHONG phai luy ke - downstream (dtm_fct_security_
*                                       trading_intraday) phai tu running-sum lai neu can
*                                       luy ke ca ngay.
* 2026-09-30		tuan.nguyenvanb		Them nhanh nen NGAY (MDDS.JAD_TRADINGVIEWHISTORY1DAY,
*                                       src_stm_code = MDDS_JAD_TRADINGVIEWHISTORY1DAY) theo
*                                       DataModel dm_atm_market_price_snapshot-MDDS.JAD_
*                                       TRADINGVIEWHISTORY1DAY - phuc vu dtm_fct_security_
*                                       trading_daily. processing_time = NULL (nen ngay).
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [FIRST-TIME 2026-10-09] append + ds_snpst_dt = ngay giao dich tung dong (giu nguyen tac 1 partition = 1 ngay nhu daily; snapshot se gan ds_snpst_dt = etl_date cho ca nam)
WITH ja_tv AS (
    SELECT
        id
        , symbol
        , tradingdate
        , minute
        , open
        , high
        , low
        , close
        , volume
    FROM {{ ft_ref('ft_ods_mdds_jad_tvhistory1m') }}
    -- [BACKFILL-UAT-ORIG] WHERE TRADINGDATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
    -- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
)

, ja_tv_day AS (
    SELECT
        id
        , symbol
        , tradingdate
        , open
        , high
        , low
        , close
        , volume
    FROM {{ ft_ref('ft_ods_mdds_jad_tradingviewhistory1day') }}
    -- [BACKFILL-UAT-ORIG] WHERE TRADINGDATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
    -- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
)

SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_TVHISTORY1MIN', "ja_tv.id") }} AS market_price_snpst_id
    , CAST(ja_tv.id AS string)                                    AS market_price_snpst_code
    , CAST('MDDS_JAD_TVHISTORY1MIN' AS string)           AS src_stm_code
    , CAST(ja_tv.symbol AS string)                                AS symbol
    , CAST(ja_tv.tradingdate AS date)                             AS trading_dt
    , CAST(ja_tv.minute AS string)                                AS processing_time
    , CAST(ja_tv.open AS decimal(23,2))                           AS open_price
    , CAST(ja_tv.high AS decimal(23,2))                           AS high_price
    , CAST(ja_tv.low AS decimal(23,2))                            AS low_price
    , CAST(ja_tv.close AS decimal(23,2))                          AS close_price
    , CAST(ja_tv.volume AS int)                                   AS vol
    , CAST(ja_tv.tradingdate AS date)                             AS ds_snpst_dt   -- [FIRST-TIME 2026-10-09] = ngay giao dich (daily: = etl_date = trading_dt)
FROM ja_tv

UNION ALL

SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_TRADINGVIEWHISTORY1DAY', "ja_tv_day.id") }} AS market_price_snpst_id
    , CAST(ja_tv_day.id AS string)                                AS market_price_snpst_code
    , CAST('MDDS_JAD_TRADINGVIEWHISTORY1DAY' AS string)  AS src_stm_code
    , CAST(ja_tv_day.symbol AS string)                            AS symbol
    , CAST(ja_tv_day.tradingdate AS date)                         AS trading_dt
    , CAST(NULL AS string)                                        AS processing_time
    , CAST(ja_tv_day.open AS decimal(23,2))                       AS open_price
    , CAST(ja_tv_day.high AS decimal(23,2))                       AS high_price
    , CAST(ja_tv_day.low AS decimal(23,2))                        AS low_price
    , CAST(ja_tv_day.close AS decimal(23,2))                      AS close_price
    , CAST(ja_tv_day.volume AS int)                               AS vol
    , CAST(ja_tv_day.tradingdate AS date)                             AS ds_snpst_dt   -- [FIRST-TIME 2026-10-09] = ngay giao dich (daily: = etl_date = trading_dt)
FROM ja_tv_day
