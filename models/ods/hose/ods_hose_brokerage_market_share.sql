/*
*--------------------------------------------------------------------*
* Program code: ods_hose_brokerage_market_share
* Program name: ODS HOSE.BROKERAGE_MARKET_SHARE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(broker_name AS string)                AS broker_name
    , CAST(member_code AS string)               AS member_code
    , CAST(buy_trading_value AS DECIMAL(20,2))  AS buy_trading_value
    , CAST(sell_trading_value AS DECIMAL(20,2)) AS sell_trading_value
    , CAST(market_share_by_value AS decimal(18,14)) AS market_share_by_value
    --, CAST(classification AS string)            AS classification
    , CAST(report_quarter AS string)            AS report_quarter
    , CAST(ds_snpst_dt AS date)                 AS ds_snpst_dt
FROM {{ source('source_hose', 'raw_brokerage_market_share_hose') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
