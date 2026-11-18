/*
*--------------------------------------------------------------------*
* Program code: atm_bond_order_book_hnx_outright_order_book
* Program name: Atomic Bond Order Book – HNX.OUTRIGHT_ORDER_BOOK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ou_bo AS (
    SELECT
        currency_code
        , original_order_no
        , payment_status
        , trading_method
        , time
        , order_no
        , remaining_term_days
        , remaining_term
        , bond_code
        , instrument_type
        , interest_payment_type
        , interest_payment_method
        , interest_rate_type
        , order_type
        , order_side
        , order_status
        , quoted_price
        , yield_rate
        , discount_rate
        , execution_price
        , volume
        , trading_value
        , trading_date
        , settlement_date
        , selling_member_code
        , selling_rep
        , selling_account_no
        , selling_broker_dealer
        , selling_proxy_entry
        , buying_member_code
        , buying_rep
        , buying_account_no
        , buying_broker_dealer
        , buying_proxy_entry
        , settlement_status
        , settlement_bond_code
        , settlement_volume
        , equivalent_bond_settlement_value
        , settlement_method
        , order_creator_rep
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_outright_order_book') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_OUTRIGHT_ORDER_BOOK', "ou_bo.order_no") }} AS bond_order_book_id
    , CAST('HNX_OUTRIGHT_ORDER_BOOK' AS string)                   AS src_stm_code
    , CAST('OUTRIGHT' AS string)                                  AS order_book_type
    , CAST(ou_bo.order_no AS string)                              AS order_no
    , CAST(ou_bo.original_order_no AS string)                     AS original_order_no
    , CAST(ou_bo.time AS string)                                  AS order_time
    , CAST(ou_bo.order_type AS string)                            AS order_type
    , CAST(ou_bo.order_side AS string)                            AS order_side
    , CAST(ou_bo.order_status AS string)                          AS order_status
    , CAST(ou_bo.order_creator_rep AS string)                     AS order_creator_rep
    , CAST(ou_bo.bond_code AS string)                             AS bond_code
    , CAST(ou_bo.instrument_type AS string)                       AS instrument_type
    , CAST(ou_bo.interest_payment_type AS string)                 AS interest_payment_type
    , CAST(ou_bo.interest_payment_method AS string)               AS interest_payment_method
    , CAST(ou_bo.interest_rate_type AS string)                    AS interest_rate_type
    , CAST(ou_bo.remaining_term_days AS bigint)                   AS remaining_term_days
    , CAST(ou_bo.remaining_term AS string)                        AS remaining_term
    , CAST(ou_bo.currency_code AS string)                         AS currency_code
    , CAST(ou_bo.quoted_price AS decimal(23,4))                   AS quoted_price
    , CAST(ou_bo.execution_price AS decimal(23,4))                AS execution_price
    , CAST(ou_bo.yield_rate AS decimal(7,4))                      AS yield_rate
    , CAST(ou_bo.discount_rate AS decimal(7,4))                   AS discount_rate
    , CAST(ou_bo.volume AS bigint)                                AS order_bond_quantity
    , CAST(ou_bo.trading_method AS string)                        AS trading_method
    , CAST(ou_bo.trading_date AS date)                            AS trading_date
    , CAST(ou_bo.trading_value AS decimal(23,2))                  AS trading_value
    , CAST(ou_bo.settlement_method AS string)                     AS settlement_method
    , CAST(ou_bo.payment_status AS string)                        AS payment_status
    , CAST(ou_bo.selling_member_code AS string)                   AS selling_member_code
    , CAST(ou_bo.selling_rep AS string)                           AS selling_rep
    , CAST(ou_bo.selling_account_no AS string)                    AS selling_account_no
    , CAST(ou_bo.selling_broker_dealer AS string)                 AS selling_broker_dealer
    , CAST(ou_bo.selling_proxy_entry AS string)                   AS selling_proxy_entry
    , CAST(ou_bo.buying_member_code AS string)                    AS buying_member_code
    , CAST(ou_bo.buying_rep AS string)                            AS buying_rep
    , CAST(ou_bo.buying_account_no AS string)                     AS buying_account_no
    , CAST(ou_bo.buying_broker_dealer AS string)                  AS buying_broker_dealer
    , CAST(ou_bo.buying_proxy_entry AS string)                    AS buying_proxy_entry
    , CAST(ou_bo.settlement_date AS date)                         AS settlement_date
    , CAST(ou_bo.settlement_status AS string)                     AS settlement_status
    , CAST(ou_bo.settlement_bond_code AS string)                  AS settlement_bond_code
    , CAST(ou_bo.settlement_volume AS bigint)                     AS settlement_bond_quantity
    , CAST(ou_bo.equivalent_bond_settlement_value AS decimal(23,2)) AS equivalent_bond_settlement_value
    , CAST(NULL AS decimal(23,2))                                 AS par_value
    , CAST(NULL AS bigint)                                        AS repo_term
    , CAST(NULL AS decimal(7,4))                                  AS repo_rate
    , CAST(NULL AS decimal(23,2))                                 AS repo_interest
    , CAST(NULL AS decimal(5,2))                                  AS risk_margin_ratio
    , CAST(NULL AS decimal(7,4))                                  AS coupon_rate
    , CAST(NULL AS decimal(23,2))                                 AS coupon_interest
    , CAST(NULL AS string)                                        AS receive_coupon_interest_ind
    , CAST(NULL AS decimal(23,2))                                 AS interest_on_coupon
    , CAST(NULL AS date)                                          AS first_settlement_date
    , CAST(NULL AS decimal(23,2))                                 AS first_settlement_value
    , CAST(NULL AS date)                                          AS second_settlement_date
    , CAST(NULL AS decimal(23,2))                                 AS second_settlement_value
    , CAST(NULL AS date)                                          AS end_trading_date
    , CAST(NULL AS string)                                        AS mark_settlement_bond_ind
FROM ou_bo
