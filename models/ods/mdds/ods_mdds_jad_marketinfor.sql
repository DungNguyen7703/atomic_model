/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_marketinfor
* Program name: ODS MDDS.JAD_MARKETINFOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-08		tuan.nguyenvanb		Bo sung cot EXCHANGECODE (JAD_MARKETINFOR; BA: bo 10 cot duoi M1)
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
    , tradingdate
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
FROM {{ ref('stg_mdds_jad_marketinfor') }}
WHERE tradingdate = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')