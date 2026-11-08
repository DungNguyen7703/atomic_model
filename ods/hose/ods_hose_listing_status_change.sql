/*
*--------------------------------------------------------------------*
* Program code: ods_hose_listing_status_change
* Program name: ODS HOSE.LISTING_STATUS_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(decision_no AS string)               AS decision_no
    , CAST(decision_date AS date)              AS decision_date
    , CAST(new_listed_shares AS bigint)        AS new_listed_shares
    , CAST(additional_listed_shares AS bigint) AS additional_listed_shares
    , CAST(delisted_shares AS bigint)          AS delisted_shares
    , CAST(exchange_transfer AS string)        AS exchange_transfer
    , CAST(listed_value AS decimal(18,2))      AS listed_value
    , CAST(additional_listed_value AS decimal(18,2)) AS additional_listed_value
    , CAST(delisted_value AS decimal(18,2))    AS delisted_value
    , CAST(ticker_symbol AS string)            AS ticker_symbol
    , CAST(issuer_name AS string)              AS issuer_name
    , CAST(effective_date AS date)             AS effective_date
    , CAST(first_trading_date AS date)         AS first_trading_date
    , CAST(last_trading_date AS date)          AS last_trading_date
    , CAST(delist_transfer_reason AS string)   AS delist_transfer_reason
    , CAST(report_month AS string)             AS report_month
    , CAST(ds_snpst_dt AS date)                AS ds_snpst_dt
FROM {{ source('source_hose', 'raw_listing_status_change_hose') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
