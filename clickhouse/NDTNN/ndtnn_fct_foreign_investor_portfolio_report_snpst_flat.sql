-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_foreign_investor_portfolio_report_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    f.snpst_dt_dim_id,
    f.rpt_log_id,
    f.section_id,
    f.dynamic_row_order,
    f.period_val,
    f.rpt_code,
    f.investor_group_nm,
    f.nationality_nm,
    f.investor_type_nm,
    f.investor_nm,
    f.bill_val,
    f.bond_val,
    f.listed_equity_fund_val,
    f.upcom_equity_val,
    f.capital_contribution_val,
    f.cash_equivalent_val,
    f.total_portfolio_val,
    f.individual_ind,
    f.fund_ind,
    f.non_fund_org_ind,
    f.foreign_bank_branch_ind,
    f.transaction_cd,
    f.src_stm_code,
    submission_cal.cdr_dt AS snpst_cdr_dt

FROM {{ ref('dtm_fct_foreign_investor_portfolio_report_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE submission_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')