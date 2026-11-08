-- [FIRST-TIME] ft_ndtnn_fct_foreign_investor_portfolio_report_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ndtnn_fct_foreign_investor_portfolio_report_snpst_flat (config ft_target='ndtnn_fct_foreign_investor_portfolio_report_snpst_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_foreign_investor_portfolio_report_snpst_flat
-- Type  : FACT
-- 2026-10-14 nghia.le: [DONG BO 01_create/02_populate] bo Foreign Investor Reporting Entity Dimension (cot FK + reporting_entity_*) khoi bang flat;
-- cột còn lại không đổi.
-- 2026-10-16 nghia.le: [DONG BO 01_create/02_populate] them foreign_bank_branch_ind, transaction_cd (truoc src_stm_code).
-- 2026-10-12 nghia.le: [FIRST-TIME NDTNN] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that) va BO loc
-- cdr_dt = etl_date de nap toan bo lich su trong 1 lan; strategy ft_ck_by_day gan ds_snpst_dt = ngay cua tung
-- dong (ft_day_column) -> 1 partition = 1 ngay nhu daily. Dim doc bang MAIN giong daily.
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

FROM {{ ft_ref('ft_dtm_fct_foreign_investor_portfolio_report_snpst') }} f   -- [FT-NEW] daily: ref('dtm_fct_foreign_investor_portfolio_report_snpst')
JOIN {{ ref('dtm_cdr_dt_dim') }} submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [FT-ORIG] WHERE submission_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
