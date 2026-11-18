/*
*--------------------------------------------------------------------*
* Program code: ods_hnx_repo_order_book
* Program name: ODS HNX.REPO_ORDER_BOOK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(currency_code AS string)                          AS currency_code
    , CAST(original_order_no AS string)                     AS original_order_no
    , CAST(payment_status AS string)                        AS payment_status
    , CAST(trading_method AS string)                        AS trading_method
    , CAST(time AS string)                                  AS time
    , CAST(order_no AS string)                              AS order_no
    , CAST(remaining_term_days AS bigint)                   AS remaining_term_days
    , CAST(remaining_term AS string)                        AS remaining_term
    , CAST(bond_code AS string)                             AS bond_code
    , CAST(instrument_type AS string)                       AS instrument_type
    , CAST(interest_payment_type AS string)                 AS interest_payment_type
    , CAST(interest_payment_method AS string)               AS interest_payment_method
    , CAST(interest_rate_type AS string)                    AS interest_rate_type
    , CAST(order_type AS string)                             AS order_type
    , CAST(order_side AS string)                             AS order_side
    , CAST(order_status AS string)                           AS order_status
    , CAST(quoted_price AS decimal(18,4))                   AS quoted_price
    , CAST(yield_rate AS decimal(10,4))                     AS yield_rate
    , CAST(discount_rate AS decimal(10,4))                  AS discount_rate
    , CAST(execution_price AS decimal(18,4))                AS execution_price
    , CAST(par_value AS decimal(18,2))                      AS par_value
    , CAST(volume AS bigint)                                 AS volume
    , CAST(first_settlement_value AS decimal(18,2))         AS first_settlement_value
    , CAST(repo_term AS bigint)                             AS repo_term
    , CAST(repo_rate AS decimal(10,4))                      AS repo_rate
    , CAST(coupon_rate AS decimal(10,4))                    AS coupon_rate
    , CAST(repo_interest AS decimal(18,2))                  AS repo_interest
    , CAST(coupon_interest AS decimal(18,2))                AS coupon_interest
    , CAST(receive_coupon_interest AS string)               AS receive_coupon_interest
    , CAST(interest_on_coupon AS decimal(18,2))             AS interest_on_coupon
    , CAST(risk_margin_ratio AS decimal(10,2))              AS risk_margin_ratio
    , CAST(trading_date AS date)                            AS trading_date
    , CAST(first_settlement_date AS date)                   AS first_settlement_date
    , CAST(second_settlement_date AS date)                  AS second_settlement_date
    , CAST(end_trading_date AS date)                        AS end_trading_date
    , CAST(second_settlement_value AS decimal(18,2))        AS second_settlement_value
    , CAST(selling_member_code AS string)                   AS selling_member_code
    , CAST(selling_rep AS string)                            AS selling_rep
    , CAST(selling_account_no AS string)                    AS selling_account_no
    , CAST(selling_broker_dealer AS string)                 AS selling_broker_dealer
    , CAST(selling_proxy_entry AS string)                   AS selling_proxy_entry
    , CAST(buying_member_code AS string)                    AS buying_member_code
    , CAST(buying_rep AS string)                             AS buying_rep
    , CAST(buying_account_no AS string)                     AS buying_account_no
    , CAST(buying_broker_dealer AS string)                  AS buying_broker_dealer
    , CAST(buying_proxy_entry AS string)                    AS buying_proxy_entry
    , CAST(settlement_method AS string)                     AS settlement_method
    , CAST(order_creator_rep AS string)                     AS order_creator_rep
    , CAST(ds_snpst_dt AS date)                             AS ds_snpst_dt
FROM {{ source('source_hnx', 'raw_repo_order_book') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
