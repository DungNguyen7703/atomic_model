/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_tradingviewhistory1day
* Program name: Staging MDDS.JAD_TRADINGVIEWHISTORY1DAY
* Created by: tuan.nguyenvanb
* Created date: 2026-09-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-30		tuan.nguyenvanb		Tao moi - phuc vu atm_market_price_snapshot (nhanh
*                                       nen ngay), theo BRD brd_MDDS_JAD_TRADINGVIEWHISTORY1DAY
*                                       (TRADINGDATE dinh dang dd/MM/yyyy).
*--------------------------------------------------------------------*
*/
{% set etl_date = modules.datetime.datetime.strptime(var("etl_date"), "%Y-%m-%d").strftime("%d/%m/%Y") %}

SELECT
    CAST(id AS string)                    AS id
    , CAST(symbol AS string)              AS symbol
    , to_date(tradingdate, 'dd/MM/yyyy')  AS tradingdate
    , CAST(open AS double)                AS open
    , CAST(high AS double)                AS high
    , CAST(low AS double)                 AS low
    , CAST(close AS double)               AS close
    , CAST(volume AS bigint)              AS volume
FROM {{ source('source_mdds', 'raw_jad_tradingviewhistory1day') }}
WHERE tradingdate = '{{ etl_date }}'