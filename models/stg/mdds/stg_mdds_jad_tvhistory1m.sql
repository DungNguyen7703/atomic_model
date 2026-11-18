/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_tvhistory1m
* Program name: Staging MDDS.JAD_TVHISTORY1M
* Created by: tuan.nguyenvanb
* Created date: 2026-09-09
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-09		tuan.nguyenvanb		Tao moi - phuc vu atm_market_price_snapshot
*                                       (LLD DTM_GSTT_fct_security_trading_intraday
*                                       sua 2026-09-07, doi nguon sang market_price_snapshot)
*--------------------------------------------------------------------*
*/
{% set etl_date = modules.datetime.datetime.strptime(var("etl_date"), "%Y-%m-%d").strftime("%d/%m/%Y") %}

SELECT
    CAST(id AS string)                    AS id
    , CAST(close AS double)               AS close
    , CAST(high AS double)                AS high
    , CAST(low AS double)                 AS low
    , CAST(minute AS string)              AS minute
    , CAST(open AS double)                AS open
    , CAST(symbol AS string)              AS symbol
    , to_date(tradingdate, 'dd/MM/yyyy')  AS tradingdate
    , CAST(volume AS bigint)              AS volume
FROM {{ source('source_mdds', 'raw_jad_tvhistory1m') }}
WHERE tradingdate = '{{ etl_date }}'