/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_mdds_order_book
* Program name: ODS HNX.MDDS_ORDER_BOOK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(ticker_symbol AS string)              AS ticker_symbol
    , CAST(trading_date AS date)                AS trading_date
    , CAST(order_receive_time AS timestamp)     AS order_receive_time
    , CAST(order_id AS string)                  AS order_id
    , CAST(order_type AS string)                AS order_type
    , CAST(order_side AS string)                AS order_side
    , CAST(volume AS bigint)                    AS volume
    , CAST(price AS decimal(18,2))              AS price
    , CAST(order_status AS string)              AS order_status
    , CAST(matched_volume AS bigint)            AS matched_volume
    , CAST(matched_price AS decimal(18,2))      AS matched_price
    , CAST(member_code AS string)               AS member_code
    , CAST(trading_account_no AS string)        AS trading_account_no
    , CAST(ds_snpst_dt AS date)                 AS ds_snpst_dt
FROM {{ source('source_hnx', 'raw_mdds_order_book_hnx') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
