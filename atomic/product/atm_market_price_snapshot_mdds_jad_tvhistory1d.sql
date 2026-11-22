/*
*--------------------------------------------------------------------*
* Program code: atm_market_price_snapshot_mdds_jad_tvhistory1d
* Program name: Atomic Market Price Snapshot - MDDS.JAD_TVHISTORY1D
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[Fix MDDS-C01] Tao model per-source (ephemeral) tu atm_market_price_snapshot: ref ODS dung ten ods_mdds_jad_tvhistory1d, src_stm_code/hash theo LLD (MDDS_JAD_TVHISTORY1D), trading_dt parse dd/MM/yyyy, vol bigint, loc data_dt.
*--------------------------------------------------------------------*
*/

WITH ja_tvd AS (
    SELECT
        id
        , close
        , high
        , low
        , open
        , symbol
        , tradingdate
        , volume
    FROM {{ ref('ods_mdds_jad_tvhistory1d') }}
    WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_TVHISTORY1D', "ja_tvd.id") }}   AS market_price_snpst_id
    , CAST(ja_tvd.id AS string)                                                  AS market_price_snpst_code
    , CAST('MDDS_JAD_TVHISTORY1D' AS string)                                     AS src_stm_code
    , CAST(ja_tvd.close AS decimal(23,2))                                        AS close_price
    , CAST(ja_tvd.high AS decimal(23,2))                                         AS high_price
    , CAST(ja_tvd.low AS decimal(23,2))                                          AS low_price
    , CAST(NULL AS string)                                                       AS processing_time
    , CAST(ja_tvd.open AS decimal(23,2))                                         AS open_price
    , CAST(ja_tvd.symbol AS string)                                              AS ticker_symbol
    , CAST(to_date(ja_tvd.tradingdate, 'dd/MM/yyyy') AS date)                    AS trading_dt
    , CAST(ja_tvd.volume AS bigint)                                              AS vol
FROM ja_tvd
