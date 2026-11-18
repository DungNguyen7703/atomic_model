/*
*--------------------------------------------------------------------*
* Program code: atm_investment_fund
* Program name: Atomic Investment Fund
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Sync LLD Atomic FMS UAT 20261006 (lld_FMS_FUNDS.yaml): operation_status_code -> cl_fms_status_id/code (JOIN STATUS);
*										fund_certificate_ticker_code -> ticker_symbol; fund_tp_code -> cl_fms_fund_tp_id/code; them open_fund_tp_code;
*										bo fund_tp_decision_nbr/par_val/identifier_description, stock_exchange_nm; *_quantity -> bigint
*--------------------------------------------------------------------*
*/

WITH fund AS (
    SELECT
        id
        , sec_id
        , bank_id
        , status_id
        , item_name
        , ename
        , short_name
        , cer_code
        , ftype_id
        , capital
        , total_qtty
        , description
        , time_of_fund
        , voucher_no
        , nav
        , nav_ccq
        , dec_date
        , par_value
        , inves_strategy
        , deschange
        , listing_date
        , number_fund_cer_first
        , open_fund_type
    FROM {{ ref('ods_fms_funds') }}
),

stat AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_fms_status') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_FUNDS', "fund.id") }}            AS investment_fund_id
    , CAST(fund.id AS string)                                              AS investment_fund_code
    , CAST('FMS_FUNDS' AS string)                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "fund.sec_id") }} AS fmc_id
    , CAST(fund.sec_id AS string)                                          AS fmc_code
    , {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "fund.bank_id") }} AS custodian_bank_id
    , CAST(fund.bank_id AS string)                                         AS custodian_bank_code
    , {{ generate_surrogate_key_bigint('FMS_STATUS', "stat.code") }}       AS cl_fms_status_id
    , CAST(stat.code AS string)                                            AS cl_fms_status_code
    , CAST(fund.item_name AS string)                                       AS investment_fund_full_nm
    , CAST(fund.ename AS string)                                           AS investment_fund_english_nm
    , CAST(fund.short_name AS string)                                      AS investment_fund_short_nm
    , CAST(fund.cer_code AS string)                                        AS ticker_symbol
    , {{ generate_surrogate_key_bigint('FMS_FUND_TYPE', "fund.ftype_id") }} AS cl_fms_fund_tp_id
    , CAST(fund.ftype_id AS string)                                        AS cl_fms_fund_tp_code
    , CAST(fund.capital AS decimal(23,2))                                  AS charter_capital_amt
    , CAST(fund.total_qtty AS bigint)                                       AS total_outstanding_unit_quantity
    , CAST(fund.description AS string)                                     AS description
    , CAST(fund.time_of_fund AS string)                                    AS fund_duration_description
    , CAST(fund.voucher_no AS string)                                      AS amendment_document_nbr
    , CAST(fund.nav AS decimal(23,2))                                      AS net_asset_val_amt
    , CAST(fund.nav_ccq AS decimal(23,2))                                  AS net_asset_val_per_unit_amt
    , CAST(fund.dec_date AS date)                                          AS decision_issue_dt
    , CAST(fund.par_value AS decimal(23,2))                                AS unit_par_val_amt
    , CAST(fund.inves_strategy AS string)                                  AS investment_strategy_description
    , CAST(fund.deschange AS string)                                       AS change_description
    , CAST(fund.listing_date AS date)                                      AS listing_dt
    , CAST(fund.number_fund_cer_first AS bigint)                            AS initial_offering_unit_quantity
    , CAST(fund.open_fund_type AS string)                                  AS open_fund_tp_code
FROM fund
    LEFT JOIN stat ON fund.status_id = stat.id