/*
*--------------------------------------------------------------------*
* Program code: dtm_investment_fund_dim
* Program name: Dtm Investment Fund Dim
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 576f001c (luật A23 PK Dim): investment_fund_id lấy trực tiếp investment_fund.investment_fund_id (Atomic) thay cho
*                                       generate_surrogate_key_bigint — khớp FK investment_fund_id mà các model khác đọc từ Atomic (logic-only, schema không đổi)
*--------------------------------------------------------------------*
*/

WITH investment_fund AS (
    SELECT
        investment_fund_id,
        investment_fund_code,
        investment_fund_full_nm,
        investment_fund_english_nm,
        investment_fund_short_nm,
        ticker_symbol,
        cl_fms_fund_tp_code,
        cl_fms_status_code,
        charter_capital_amt,
        total_outstanding_unit_quantity,
        net_asset_val_amt,
        net_asset_val_per_unit_amt,
        unit_par_val_amt,
        fund_duration_description,
        decision_issue_dt,
        listing_dt,
        initial_offering_unit_quantity,
        investment_strategy_description,
        description,
        change_description,
        amendment_document_nbr,
        fmc_id,
        fmc_code,
        custodian_bank_id,
        custodian_bank_code,
        src_stm_code
    FROM {{ ref('atm_investment_fund') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
)

SELECT
    CAST(investment_fund_id AS string)                               AS investment_fund_id,
    CAST(investment_fund_code AS string)                             AS investment_fund_code,
    CAST(investment_fund_full_nm AS string)                          AS investment_fund_full_nm,
    CAST(investment_fund_english_nm AS string)                       AS investment_fund_english_nm,
    CAST(investment_fund_short_nm AS string)                         AS investment_fund_short_nm,
    CAST(ticker_symbol AS string)                                    AS fund_certificate_ticker_code,
    CAST(cl_fms_fund_tp_code AS string)                              AS fund_tp_code,
    CAST(cl_fms_status_code AS string)                               AS operation_status_code,
    CAST(charter_capital_amt AS decimal(23,2))                       AS charter_capital_amt,
    CAST(total_outstanding_unit_quantity AS bigint)                  AS total_outstanding_unit_quantity,
    CAST(net_asset_val_amt AS decimal(23,2))                         AS net_asset_val_amt,
    CAST(net_asset_val_per_unit_amt AS decimal(23,2))                AS net_asset_val_per_unit_amt,
    CAST(unit_par_val_amt AS decimal(23,2))                          AS unit_par_val_amt,
    CAST(fund_duration_description AS string)                        AS fund_duration_description,
    CAST(decision_issue_dt AS date)                                  AS decision_issue_dt,
    CAST(listing_dt AS date)                                         AS listing_dt,
    CAST(initial_offering_unit_quantity AS bigint)                   AS initial_offering_unit_quantity,
    CAST(investment_strategy_description AS string)                  AS investment_strategy_description,
    CAST(description AS string)                                      AS description,
    CAST(change_description AS string)                               AS change_description,
    CAST(amendment_document_nbr AS string)                           AS amendment_document_nbr,
    CAST(fmc_id AS string)                                           AS fmc_id,
    CAST(fmc_code AS string)                                         AS fmc_code,
    CAST(custodian_bank_id AS string)                                AS custodian_bank_id,
    CAST(custodian_bank_code AS string)                              AS custodian_bank_code,
    CAST(src_stm_code AS string)                                     AS src_stm_code
FROM investment_fund
