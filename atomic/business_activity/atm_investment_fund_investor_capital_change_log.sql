/*
*--------------------------------------------------------------------*
* Program code: atm_investment_fund_investor_capital_change_log
* Program name: Atomic Investment Fund Investor Capital Change Log
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , date_created
        , mbf_id
        , tx_date
        , tx_num
        , aoorp
        , bus_date
        , prepercent
        , aft_percent
        , pre_qtty
        , aft_qtty
        , precapital
        , aft_capital
    FROM {{ ref('ods_fms_mb_change') }}
    WHERE date_created >= TIMESTAMP '{{ var("etl_date") }} 00:00:00'
        AND date_created <  TIMESTAMP '{{ var("etl_date") }} 00:00:00' + INTERVAL 1 DAY

)

SELECT
    {{ generate_surrogate_key_bigint('FMS_MB_CHANGE', "id") }}     AS investment_fund_investor_capital_change_log_id
    , CAST(id AS string)                                           AS investment_fund_investor_capital_change_log_code
    , CAST('FMS_MB_CHANGE' AS string)                              AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_MB_FUND', "mbf_id") }} AS investment_fund_investor_membership_id
    , CAST(mbf_id AS string)                                       AS investment_fund_investor_membership_code
    , CAST(tx_date AS timestamp)                                   AS transaction_tms
    , CAST(tx_num AS string)                                       AS transaction_nbr
    , CAST(aoorp AS string)                                        AS capital_change_tp_code
    , CAST(bus_date AS timestamp)                                  AS settlement_tms
    , CAST(prepercent AS decimal(5,2))                             AS pre_transaction_ownership_percentage
    , CAST(aft_percent AS decimal(5,2))                            AS post_transaction_ownership_percentage
    , CAST(pre_qtty AS bigint)                                     AS pre_transaction_unit_quantity
    , CAST(aft_qtty AS bigint)                                     AS post_transaction_unit_quantity
    , CAST(precapital AS decimal(23,2))                            AS pre_transaction_capital_amt
    , CAST(aft_capital AS decimal(23,2))                           AS post_transaction_capital_amt
    , CAST(date_created AS date)                                   AS data_dt
FROM src
