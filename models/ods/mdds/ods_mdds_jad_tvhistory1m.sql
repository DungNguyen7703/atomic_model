/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_tvhistory1m
* Program name: ODS MDDS.JAD_TVHISTORY1M
* Created by: tuan.nguyenvanb
* Created date: 2026-09-09
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-09		tuan.nguyenvanb		Tao moi - phuc vu atm_market_price_snapshot
*--------------------------------------------------------------------*
*/

SELECT
    id
    , symbol
    , tradingdate
    , minute
    , open
    , high
    , low
    , close
    , volume
FROM {{ ref('stg_mdds_jad_tvhistory1m') }}
WHERE tradingdate = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
