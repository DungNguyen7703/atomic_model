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
    FROM {{ ref('ods_mdds_jad_tvhistory1m') }}
    WHERE TRADINGDATE = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
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
    FROM {{ ref('ods_mdds_jad_tradingviewhistory1day') }}
    WHERE TRADINGDATE = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
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
FROM ja_tv_day
