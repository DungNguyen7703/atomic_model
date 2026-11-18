-- [FIRST-TIME] ft_stg_mdds_jad_marketinfor: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily stg_mdds_jad_marketinfor (config ft_target='jad_marketinfor', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_marketinfor
* Program name: Staging MDDS.JAD_MARKETINFOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-08		tuan.nguyenvanb		Bo sung cot EXCHANGECODE tu nguon JAD_MARKETINFOR (BA: bo 10 cot duoi M1)
*--------------------------------------------------------------------*
*/

SELECT
    CAST(historyid AS string)                AS historyid
    , CAST(id AS string)                     AS id
    , CAST(marketindex AS double)            AS marketindex
    , CAST(indextime AS string)              AS indextime
    , CAST(indexcolor AS string)             AS indexcolor
    , CAST(indexchange AS double)            AS indexchange
    , CAST(indexpercentchange AS double)     AS indexpercentchange
    , CAST(totalvolume AS double)            AS totalvolume
    , CAST(totalvalue AS double)             AS totalvalue
    , CAST(marketstatus AS string)           AS marketstatus
    , CAST(advances AS int)                  AS advances
    , CAST(declines AS int)                  AS declines
    , CAST(nochange AS int)                  AS nochange
    , CAST(advancesvolumn AS bigint)         AS advancesvolumn
    , CAST(declinesvolumn AS bigint)         AS declinesvolumn
    , CAST(nochangevolumn AS bigint)         AS nochangevolumn
    , CAST(marketid AS string)               AS marketid
    , CAST(marketcode AS string)             AS marketcode
    , CAST(prv_prior_market_index AS double) AS prv_prior_market_index
    , CAST(pt_total_qtty AS bigint)          AS pt_total_qtty
    , CAST(pt_total_value AS double)         AS pt_total_value
    , CAST(pt_total_trade AS double)         AS pt_total_trade
    , CAST(numberofce AS int)                AS numberofce
    , CAST(numberoffl AS int)                AS numberoffl
    , CAST(oddlottotalvalue AS double)       AS oddlottotalvalue
    , CAST(oddlottotalvolume AS bigint)      AS oddlottotalvolume
    , to_date(tradingdate, 'dd/MM/yyyy')     AS tradingdate
    , CAST(tscprodgrpid AS string)           AS tscprodgrpid
    , CAST(haltrsncode AS string)            AS haltrsncode
    , CAST(indextypecode AS string)          AS indextypecode
    , CAST(open AS double)                   AS open
    , CAST(low AS double)                    AS low
    , CAST(high AS double)                   AS high
    , CAST(avr_chg_index AS double)          AS avr_chg_index
    , CAST(avr_market_index AS double)       AS avr_market_index
    , CAST(avr_pct_index AS double)          AS avr_pct_index
    , CAST(avr_prior_market_index AS double) AS avr_prior_market_index
    , CAST(indexname AS string)              AS indexname
    , CAST(prevstatus AS string)             AS prevstatus
    , CAST(sequence AS bigint)               AS sequence
    , CAST(sequencemsg AS string)            AS sequencemsg
    , CAST(totaltrade AS bigint)             AS totaltrade
    , CAST(exchangecode AS string)           AS exchangecode
FROM {{ source('source_mdds', 'raw_jad_marketinfor') }}
-- [BACKFILL-UAT-ORIG] WHERE date_format(to_date(TRADINGDATE,'dd/MM/yyyy'), 'yyyy-MM-dd') BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]