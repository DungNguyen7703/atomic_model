/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_tradingviewhistory1day
* Program name: ODS MDDS.JAD_TRADINGVIEWHISTORY1DAY
* Created by: tuan.nguyenvanb
* Created date: 2026-09-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-30		tuan.nguyenvanb		Tao moi - phuc vu atm_market_price_snapshot (nen ngay)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , symbol
    , tradingdate
    , open
    , high
    , low
    , close
    , volume
FROM {{ ref('stg_mdds_jad_tradingviewhistory1day') }}
WHERE tradingdate = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
