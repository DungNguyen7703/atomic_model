/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_outstanding_shares
* Program name: ODS VSDC.OUTSTANDING_SHARES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(ticker_symbol AS string)          AS ticker_symbol
    , CAST(total_issued_shares AS bigint)  AS total_issued_shares
    , CAST(treasury_shares AS bigint)      AS treasury_shares
    , CAST(outstanding_shares AS bigint)   AS outstanding_shares
    , CAST(free_float_shares AS bigint)    AS free_float_shares
    , CAST(restricted_shares AS bigint)    AS restricted_shares
    , CAST(voting_shares AS bigint)        AS voting_shares
    , CAST(isin_code AS string)            AS isin_code
    , CAST(transaction_date AS date)       AS transaction_date
    , CAST(report_day AS int)              AS report_day
    , CAST(report_month AS int)            AS report_month
    , CAST(report_year AS int)             AS report_year
FROM {{ source('source_vsdc', 'raw_outstanding_shares') }}
WHERE transaction_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')