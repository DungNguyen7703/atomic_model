/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_listed_securities_list
* Program name: ODS HNX.LISTED_SECURITIES_LIST
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(ticker_symbol AS string)            AS ticker_symbol
    , CAST(issuer_name AS string)            AS issuer_name
    , CAST(listed_shares AS bigint)          AS listed_shares
    , CAST(outstanding_shares AS bigint)     AS outstanding_shares
    , CAST(reference_price AS decimal(23,2)) AS reference_price
    , CAST(report_date AS date)              AS report_date
    , CAST(report_day AS int)                AS report_day
    , CAST(report_month AS int)              AS report_month
    , CAST(report_year AS int)               AS report_year
FROM {{ source('source_hnx', 'raw_listed_securities_list_hnx') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
