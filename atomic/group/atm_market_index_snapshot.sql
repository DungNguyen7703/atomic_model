/*
*--------------------------------------------------------------------*
* Program code: atm_market_index_snapshot
* Program name: Atomic Market Index Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ja_ma AS (
    SELECT
        historyid
        , marketcode
        , marketid
        , id
        , tradingdate
        , indextime
        , indextypecode
        , marketstatus
        , indexcolor
        , haltrsncode
        , marketindex
        , indexchange
        , indexpercentchange
        , open
        , high
        , low
        , prv_prior_market_index
        , totalvolume
        , totalvalue
        , advances
        , declines
        , nochange
        , numberofce
        , numberoffl
        , advancesvolumn
        , declinesvolumn
        , nochangevolumn
        , oddlottotalvalue
        , oddlottotalvolume
        , pt_total_qtty
        , pt_total_value
        , pt_total_trade
        , tscprodgrpid
        , indexname
        , sequence
    FROM {{ ref('ods_mdds_jad_marketinfor') }}
    WHERE TRADINGDATE = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_MARKETINFOR', "ja_ma.historyid") }} AS market_index_snpst_id
    , CAST(ja_ma.historyid AS string)                                              AS market_index_snpst_code
    , CAST('MDDS_JAD_MARKETINFOR' AS string)                                       AS src_stm_code
    , CAST(ja_ma.marketcode AS string)                                             AS market_code
    , CAST(ja_ma.marketid AS string)                                               AS market_id
    , CAST(ja_ma.id AS string)                                                     AS jadapter_id
    , CAST(ja_ma.tradingdate AS date)                                              AS trading_dt
    , CAST(ja_ma.indextime AS string)                                              AS index_time
    , CAST(ja_ma.indextypecode AS string)                                          AS index_tp_code
    , CAST(ja_ma.marketstatus AS string)                                           AS market_status_code
    , CAST(ja_ma.indexcolor AS string)                                             AS index_color_code
    , CAST(ja_ma.haltrsncode AS string)                                            AS halt_reason_code
    , CAST(ja_ma.marketindex AS decimal(23,2))                                     AS market_index_val
    , CAST(ja_ma.indexchange AS decimal(23,2))                                     AS index_change
    , CAST(ja_ma.indexpercentchange AS decimal(5,2))                               AS index_percent_change
    , CAST(ja_ma.open AS decimal(23,2))                                            AS open_index
    , CAST(ja_ma.high AS decimal(23,2))                                            AS high_index
    , CAST(ja_ma.low AS decimal(23,2))                                             AS low_index
    , CAST(ja_ma.prv_prior_market_index AS decimal(23,2))                          AS prior_index
    , CAST(ja_ma.totalvolume AS int)                                               AS total_vol
    , CAST(ja_ma.totalvalue AS decimal(23,2))                                      AS total_val
    , CAST(ja_ma.advances AS int)                                                  AS advances_count
    , CAST(ja_ma.declines AS int)                                                  AS declines_count
    , CAST(ja_ma.nochange AS int)                                                  AS no_change_count
    , CAST(ja_ma.numberofce AS int)                                                AS ceiling_count
    , CAST(ja_ma.numberoffl AS int)                                                AS floor_count
    , CAST(ja_ma.advancesvolumn AS int)                                            AS advances_vol
    , CAST(ja_ma.declinesvolumn AS int)                                            AS declines_vol
    , CAST(ja_ma.nochangevolumn AS int)                                            AS no_change_vol
    , CAST(ja_ma.oddlottotalvalue AS decimal(23,2))                                AS odd_lot_total_val
    , CAST(ja_ma.oddlottotalvolume AS int)                                         AS odd_lot_total_vol
    , CAST(ja_ma.pt_total_qtty AS int)                                             AS pt_total_vol
    , CAST(ja_ma.pt_total_value AS decimal(23,2))                                  AS pt_total_val
    , CAST(ja_ma.pt_total_trade AS int)                                            AS pt_total_trade_count
    , CAST(ja_ma.tscprodgrpid AS string)                                           AS tsc_product_group_id
    , CAST(ja_ma.indexname AS string)                                              AS index_nm
    , CAST(ja_ma.sequence AS bigint)                                               AS sequence
FROM ja_ma