/*
*--------------------------------------------------------------------*
* Program code: atm_mdds_order_book_hose_mdds_order_book
* Program name: Atomic MDDS Order Book – HOSE.MDDS_ORDER_BOOK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH md_bo AS (
    SELECT
        ticker_symbol
        , trading_date
        , order_receive_time
        , order_id
        , order_type
        , order_side
        , volume
        , price
        , order_status
        , matched_volume
        , matched_price
        , member_code
        , trading_account_no
        , ds_snpst_dt
    FROM {{ ref('ods_hose_mdds_order_book') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HOSE_MDDS_ORDER_BOOK', "md_bo.order_id") }} AS mdds_order_book_id
    , CAST(md_bo.ticker_symbol AS string)              AS ticker_symbol
    , CAST('HOSE_MDDS_ORDER_BOOK' AS string)           AS src_stm_code
    , CAST(md_bo.trading_date AS date)                 AS trading_date
    , CAST(md_bo.order_receive_time AS timestamp)      AS order_receive_time
    , CAST(md_bo.order_id AS string)                   AS order_id
    , CAST(md_bo.order_type AS string)                 AS order_type
    , CAST(md_bo.order_side AS string)                 AS order_side
    , CAST(md_bo.volume AS bigint)                     AS order_quantity
    , CAST(md_bo.price AS decimal(23,2))               AS order_price
    , CAST(md_bo.order_status AS string)               AS order_status
    , CAST(md_bo.matched_volume AS bigint)              AS matched_quantity
    , CAST(md_bo.matched_price AS decimal(23,2))        AS matched_price
    , CAST(md_bo.member_code AS string)                AS member_code
    , CAST(md_bo.trading_account_no AS string)         AS trading_account_no
FROM md_bo
