-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_portfolio_asset_structure_flat
-- Type  : FACT
-- 2026-10-17 nghia.le: [MOI] Bang rieng cho chi tieu Co cau danh muc theo loai hinh tai san (Nhom 7, K_NDTNN_43/45-49).
-- Gop SUM theo NGAY NOP bao cao tu fct_foreign_investor_portfolio_report_snpst (1 dong / ngay); cac flat khac khong doi.
-- ────────────────────────────────────────────────────────────

SELECT
    CAST(SUM(f.total_portfolio_val) AS decimal(23,2))       AS total_portfolio_val,
    CAST(SUM(f.bill_val) AS decimal(23,2))                  AS bill_val,
    CAST(SUM(f.listed_equity_fund_val) AS decimal(23,2))    AS listed_equity_fund_val,
    CAST(SUM(f.bond_val) AS decimal(23,2))                  AS bond_val,
    CAST(SUM(f.upcom_equity_val) AS decimal(23,2))          AS upcom_equity_val,
    CAST(SUM(f.capital_contribution_val) AS decimal(23,2))  AS capital_contribution_val,
    CAST(SUM(f.cash_equivalent_val) AS decimal(23,2))       AS cash_equivalent_val,
    f.src_stm_code,
    submission_cal.cdr_dt AS snpst_cdr_dt

FROM {{ ref('dtm_fct_foreign_investor_portfolio_report_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE submission_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
GROUP BY f.src_stm_code, submission_cal.cdr_dt
