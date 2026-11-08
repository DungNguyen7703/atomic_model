-- [FIRST-TIME] ft_ndtnn_fct_portfolio_asset_structure_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ndtnn_fct_portfolio_asset_structure_flat (config ft_target='ndtnn_fct_portfolio_asset_structure_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_portfolio_asset_structure_flat
-- Type  : FACT
-- 2026-10-17 nghia.le: [FIRST-TIME NDTNN] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that) va BO loc
-- cdr_dt = etl_date de nap toan bo lich su trong 1 lan; strategy ft_ck_by_day gan ds_snpst_dt = ngay nop cua tung
-- dong (ft_day_column = snpst_cdr_dt) -> 1 partition = 1 ngay nhu daily.
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

FROM {{ ft_ref('ft_dtm_fct_foreign_investor_portfolio_report_snpst') }} f   -- [FT-NEW] daily: ref('dtm_fct_foreign_investor_portfolio_report_snpst')
JOIN {{ ref('dtm_cdr_dt_dim') }} submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [FT-ORIG] WHERE submission_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
GROUP BY f.src_stm_code, submission_cal.cdr_dt
