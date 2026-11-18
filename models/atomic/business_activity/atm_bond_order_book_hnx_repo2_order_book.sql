/*
*--------------------------------------------------------------------*
* Program code: atm_bond_order_book_hnx_repo2_order_book
* Program name: Atomic Bond Order Book – HNX.REPO2_ORDER_BOOK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH re2_bo AS (
    SELECT
        payment_status
        , currency_code
        , trading_method
        , time
        , order_no
        , original_order_no
        , remaining_term_days
        , remaining_term
        , bond_code
        , order_type
        , instrument_type
        , interest_payment_type
        , interest_payment_method
        , interest_rate_type
        , order_side
        , order_status
        , risk_margin_ratio
        , quoted_price
        , yield_rate
        , discount_rate
        , execution_price
        , volume
        , par_value
        , first_settlement_value
        , repo_term
        , repo_interest
        , repo_rate
        , coupon_rate
        , receive_coupon_interest
        , coupon_interest
        , second_settlement_value
        , interest_on_coupon
        , trading_date
        , first_settlement_date
        , end_trading_date
        , second_settlement_date
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
        , settlement_method
        , order_creator_rep
        , settlement_status
        , settlement_bond_code
        , settlement_volume
        , equivalent_bond_settlement_value
        , mark_settlement_bond
        , ds_snpst_dt
    FROM {{ ref('ods_hnx_repo2_order_book') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_REPO2_ORDER_BOOK', "re2_bo.order_no") }} AS bond_order_book_id
    , CAST('HNX_REPO2_ORDER_BOOK' AS string)                       AS src_stm_code
    , CAST('REPO2' AS string)                                      AS order_book_type
    , CAST(re2_bo.order_no AS string)                              AS order_no
    , CAST(re2_bo.original_order_no AS string)                     AS original_order_no
    , CAST(re2_bo.time AS string)                                  AS order_time
    , CAST(re2_bo.order_type AS string)                            AS order_type
    , CAST(re2_bo.order_side AS string)                            AS order_side
    , CAST(re2_bo.order_status AS string)                          AS order_status
    , CAST(re2_bo.order_creator_rep AS string)                     AS order_creator_rep
    , CAST(re2_bo.bond_code AS string)                             AS bond_code
    , CAST(re2_bo.instrument_type AS string)                       AS instrument_type
    , CAST(re2_bo.interest_payment_type AS string)                 AS interest_payment_type
    , CAST(re2_bo.interest_payment_method AS string)               AS interest_payment_method
    , CAST(re2_bo.interest_rate_type AS string)                    AS interest_rate_type
    , CAST(re2_bo.remaining_term_days AS bigint)                   AS remaining_term_days
    , CAST(re2_bo.remaining_term AS string)                        AS remaining_term
    , CAST(re2_bo.currency_code AS string)                         AS currency_code
    , CAST(re2_bo.quoted_price AS decimal(23,4))                   AS quoted_price
    , CAST(re2_bo.execution_price AS decimal(23,4))                AS execution_price
    , CAST(re2_bo.yield_rate AS decimal(7,4))                      AS yield_rate
    , CAST(re2_bo.discount_rate AS decimal(7,4))                   AS discount_rate
    , CAST(re2_bo.volume AS bigint)                                AS order_bond_quantity
    , CAST(re2_bo.trading_method AS string)                        AS trading_method
    , CAST(re2_bo.trading_date AS date)                            AS trading_date
    , CAST(NULL AS decimal(23,2))                                  AS trading_value
    , CAST(re2_bo.settlement_method AS string)                     AS settlement_method
    , CAST(re2_bo.payment_status AS string)                        AS payment_status
    , CAST(re2_bo.selling_member_code AS string)                   AS selling_member_code
    , CAST(re2_bo.selling_rep AS string)                           AS selling_rep
    , CAST(re2_bo.selling_account_no AS string)                    AS selling_account_no
    , CAST(re2_bo.selling_broker_dealer AS string)                 AS selling_broker_dealer
    , CAST(re2_bo.selling_proxy_entry AS string)                   AS selling_proxy_entry
    , CAST(re2_bo.buying_member_code AS string)                    AS buying_member_code
    , CAST(re2_bo.buying_rep AS string)                            AS buying_rep
    , CAST(re2_bo.buying_account_no AS string)                     AS buying_account_no
    , CAST(re2_bo.buying_broker_dealer AS string)                  AS buying_broker_dealer
    , CAST(re2_bo.buying_proxy_entry AS string)                    AS buying_proxy_entry
    , CAST(NULL AS date)                                           AS settlement_date
    , CAST(re2_bo.settlement_status AS string)                     AS settlement_status
    , CAST(re2_bo.settlement_bond_code AS string)                  AS settlement_bond_code
    , CAST(re2_bo.settlement_volume AS bigint)                     AS settlement_bond_quantity
    , CAST(re2_bo.equivalent_bond_settlement_value AS decimal(23,2)) AS equivalent_bond_settlement_value
    , CAST(re2_bo.par_value AS decimal(23,2))                      AS par_value
    , CAST(re2_bo.repo_term AS bigint)                             AS repo_term
    , CAST(re2_bo.repo_rate AS decimal(7,4))                       AS repo_rate
    , CAST(re2_bo.repo_interest AS decimal(23,2))                  AS repo_interest
    , CAST(re2_bo.risk_margin_ratio AS decimal(5,2))               AS risk_margin_ratio
    , CAST(re2_bo.coupon_rate AS decimal(7,4))                     AS coupon_rate
    , CAST(re2_bo.coupon_interest AS decimal(23,2))                AS coupon_interest
    , CAST(re2_bo.receive_coupon_interest AS string)               AS receive_coupon_interest_ind
    , CAST(re2_bo.interest_on_coupon AS decimal(23,2))             AS interest_on_coupon
    , CAST(re2_bo.first_settlement_date AS date)                   AS first_settlement_date
    , CAST(re2_bo.first_settlement_value AS decimal(23,2))         AS first_settlement_value
    , CAST(re2_bo.second_settlement_date AS date)                  AS second_settlement_date
    , CAST(re2_bo.second_settlement_value AS decimal(23,2))        AS second_settlement_value
    , CAST(re2_bo.end_trading_date AS date)                        AS end_trading_date
    , CAST(re2_bo.mark_settlement_bond AS string)                  AS mark_settlement_bond_ind
FROM re2_bo
