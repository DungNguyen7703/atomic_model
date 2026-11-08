-- [FIRST-TIME] ft_atm_market_index_snapshot: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_market_index_snapshot (config ft_target='market_index_snapshot', macro macros/first_time).
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

{{ config(incremental_strategy='append') }}   -- [FIRST-TIME 2026-10-09] append + ds_snpst_dt = ngay giao dich tung dong (giu nguyen tac 1 partition = 1 ngay nhu daily; snapshot se gan ds_snpst_dt = etl_date cho ca nam)
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
    FROM {{ ft_ref('ft_ods_mdds_jad_marketinfor') }}
    -- [BACKFILL-UAT-ORIG] WHERE TRADINGDATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
    -- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
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
    , CAST(ja_ma.tradingdate AS date)                             AS ds_snpst_dt   -- [FIRST-TIME 2026-10-09] = ngay giao dich (daily: = etl_date = trading_dt)
FROM ja_ma