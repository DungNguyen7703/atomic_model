-- [FIRST-TIME] ft_stg_mdds_jad_marketinfor_from_uat: nap lich su MDDS tu Oracle UAT (UBCK.JAD_MARKETINFOR_UAT) len staging PROD.
-- Ghi vao bang that prod_staging.mdds_stg.jad_marketinfor (config ft_target, macro macros/first_time). Moi dong ghi vao partition data_dt = ngay giao dich (tradingdate dd/MM/yyyy);
-- INSERT OVERWRITE dynamic partition nen chay lai khong trung. Tuy chon chia nho: --vars '{backfill_from: "2026-01-01", backfill_to: "2026-01-31"}'.
/*
*--------------------------------------------------------------------*
* Program code: ft_stg_mdds_jad_marketinfor_from_uat
* Program name: Staging MDDS.JAD_MARKETINFOR (tu Oracle UAT)
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Keo du lieu da dump tu staging UAT len Oracle (UBCK.JAD_MARKETINFOR_UAT) vao staging PROD. Cot/kieu theo DDL prod_staging.mdds_stg.jad_marketinfor (43 cot nghiep vu + data_dt + ds_etl_pcs_tms); tradingdate giu STRING dd/MM/yyyy, data_dt = to_date(tradingdate).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(historyid AS string)                    AS historyid
    , CAST(avr_chg_index AS double)                AS avr_chg_index
    , CAST(avr_market_index AS double)             AS avr_market_index
    , CAST(avr_pct_index AS double)                AS avr_pct_index
    , CAST(avr_prior_market_index AS double)       AS avr_prior_market_index
    , CAST(id AS string)                           AS id
    , CAST(prv_prior_market_index AS double)       AS prv_prior_market_index
    , CAST(pt_total_qtty AS decimal(19,0))         AS pt_total_qtty
    , CAST(pt_total_trade AS double)               AS pt_total_trade
    , CAST(pt_total_value AS double)               AS pt_total_value
    , CAST(advances AS bigint)                     AS advances
    , CAST(advancesvolumn AS decimal(19,0))        AS advancesvolumn
    , CAST(declines AS bigint)                     AS declines
    , CAST(declinesvolumn AS decimal(19,0))        AS declinesvolumn
    , CAST(haltrsncode AS string)                  AS haltrsncode
    , CAST(high AS double)                         AS high
    , CAST(indexchange AS double)                  AS indexchange
    , CAST(indexcolor AS string)                   AS indexcolor
    , CAST(indexname AS string)                    AS indexname
    , CAST(indexpercentchange AS double)           AS indexpercentchange
    , CAST(indextime AS string)                    AS indextime
    , CAST(indextypecode AS string)                AS indextypecode
    , CAST(low AS double)                          AS low
    , CAST(marketcode AS string)                   AS marketcode
    , CAST(marketid AS string)                     AS marketid
    , CAST(marketindex AS double)                  AS marketindex
    , CAST(marketstatus AS string)                 AS marketstatus
    , CAST(nochange AS bigint)                     AS nochange
    , CAST(nochangevolumn AS decimal(19,0))        AS nochangevolumn
    , CAST(numberofce AS bigint)                   AS numberofce
    , CAST(numberoffl AS bigint)                   AS numberoffl
    , CAST(oddlottotalvalue AS double)             AS oddlottotalvalue
    , CAST(oddlottotalvolume AS decimal(19,0))     AS oddlottotalvolume
    , CAST(open AS double)                         AS open
    , CAST(prevstatus AS string)                   AS prevstatus
    , CAST(sequence AS bigint)                     AS sequence
    , CAST(sequencemsg AS string)                  AS sequencemsg
    , CAST(totaltrade AS decimal(19,0))            AS totaltrade
    , CAST(totalvalue AS double)                   AS totalvalue
    , CAST(totalvolume AS double)                  AS totalvolume
    , CAST(tradingdate AS string)                  AS tradingdate
    , CAST(tscprodgrpid AS string)                 AS tscprodgrpid
    , CAST(exchangecode AS string)                 AS exchangecode
    , to_date(tradingdate, 'dd/MM/yyyy')              AS data_dt
FROM {{ source('source_mdds_uat', 'raw_jad_marketinfor_uat') }}