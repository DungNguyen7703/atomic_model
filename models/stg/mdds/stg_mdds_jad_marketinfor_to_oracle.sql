{{
    config(
        materialized = 'view',
        schema = var('stg_mdds_schema'),
        alias = 'jad_marketinfor_to_oracle_v',
        post_hook = [
            "INSERT INTO {{ var('src_mdds_schema') }}.JAD_MARKETINFOR_UAT (historyid, id, marketindex, indextime, indexcolor, indexchange, indexpercentchange, totalvolume, totalvalue, marketstatus, advances, declines, nochange, advancesvolumn, declinesvolumn, nochangevolumn, marketid, marketcode, prv_prior_market_index, pt_total_qtty, pt_total_value, pt_total_trade, numberofce, numberoffl, oddlottotalvalue, oddlottotalvolume, tradingdate, tscprodgrpid, haltrsncode, indextypecode, open, low, high, avr_chg_index, avr_market_index, avr_pct_index, avr_prior_market_index, indexname, prevstatus, sequence, sequencemsg, totaltrade, exchangecode) SELECT /*+ REPARTITION(256) */ * FROM {{ this }}"
        ],
        tags = ['layer_staging', 'domain_mdds', 'push_to_oracle']
    )
}}

/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_marketinfor_to_oracle
* Program name: Day MDDS.JAD_MARKETINFOR tu staging UAT (Iceberg) vao Oracle oracle_viettel_2.UBCK_PROD.JAD_MARKETINFOR_UAT
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Chieu nguoc voi stg_mdds_jad_marketinfor: doc FULL staging.uat_MDDS_stg.jad_marketinfor (khong loc etl_date) -> INSERT vao Oracle UBCK_PROD.. tradingdate doi lai dd/MM/yyyy (varchar2). Hint REPARTITION(8) de ghi JDBC song song 8 ket noi. Khong gom ds_etl_pcs_tms. Bang Oracle UBCK_PROD phai TRUNCATE truoc khi chay lai (hook chi INSERT).
*--------------------------------------------------------------------*
*/

SELECT
    historyid
    , id
    , marketindex
    , indextime
    , indexcolor
    , indexchange
    , indexpercentchange
    , totalvolume
    , totalvalue
    , marketstatus
    , advances
    , declines
    , nochange
    , advancesvolumn
    , declinesvolumn
    , nochangevolumn
    , marketid
    , marketcode
    , prv_prior_market_index
    , pt_total_qtty
    , pt_total_value
    , pt_total_trade
    , numberofce
    , numberoffl
    , oddlottotalvalue
    , oddlottotalvolume
    , date_format(tradingdate, 'dd/MM/yyyy') AS tradingdate
    , tscprodgrpid
    , haltrsncode
    , indextypecode
    , open
    , low
    , high
    , avr_chg_index
    , avr_market_index
    , avr_pct_index
    , avr_prior_market_index
    , indexname
    , prevstatus
    , sequence
    , sequencemsg
    , totaltrade
    , exchangecode
FROM {{ source('source_mdds_uat_stg', 'raw_jad_marketinfor') }}
