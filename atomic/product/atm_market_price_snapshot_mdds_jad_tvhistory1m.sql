/*
*--------------------------------------------------------------------*
* Program code: atm_market_price_snapshot_mdds_jad_tvhistory1m
* Program name: Atomic Market Price Snapshot - MDDS.JAD_TVHISTORY1M
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[Fix MDDS-C01] Tao model per-source (ephemeral) tu atm_market_price_snapshot: ref ODS dung ten ods_mdds_jad_tvhistory1m, src_stm_code/hash theo LLD (MDDS_JAD_TVHISTORY1M), trading_dt parse dd/MM/yyyy, vol bigint, loc data_dt.
*--------------------------------------------------------------------*
*/

WITH ja_tv AS (
    SELECT
        id
        , close
        , high
        , low
        , minute
        , open
        , symbol
        , tradingdate
        , volume
    FROM {{ ref('ods_mdds_jad_tvhistory1m') }}
    WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_TVHISTORY1M', "ja_tv.id") }}   AS market_price_snpst_id
    , CAST(ja_tv.id AS string)                                                  AS market_price_snpst_code
    , CAST('MDDS_JAD_TVHISTORY1M' AS string)                                    AS src_stm_code
    , CAST(ja_tv.close AS decimal(23,2))                                        AS close_price
    , CAST(ja_tv.high AS decimal(23,2))                                         AS high_price
    , CAST(ja_tv.low AS decimal(23,2))                                          AS low_price
    , CAST(ja_tv.minute AS string)                                              AS processing_time
    , CAST(ja_tv.open AS decimal(23,2))                                         AS open_price
    , CAST(ja_tv.symbol AS string)                                              AS ticker_symbol
    , CAST(to_date(ja_tv.tradingdate, 'dd/MM/yyyy') AS date)                    AS trading_dt
    , CAST(ja_tv.volume AS bigint)                                              AS vol
FROM ja_tv
