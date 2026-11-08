/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_brokerage_market_share
* Program name: ODS HNX.BROKERAGE_MARKET_SHARE
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
    , CAST(total_trading_value AS decimal(20,2)) AS total_trading_value
    , CAST(market_share_by_value AS decimal(10,2)) AS market_share_by_value
    , CAST(classification AS string)            AS classification
    , CAST(report_quarter AS string)            AS report_quarter
    , CAST(ds_snpst_dt AS date)                 AS ds_snpst_dt
FROM {{ source('source_hnx', 'raw_brokerage_market_share_hnx') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
