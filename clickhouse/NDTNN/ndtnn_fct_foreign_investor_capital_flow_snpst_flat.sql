-- ────────────────────────────────────────────────────────────
-- Model : ndtnn_fct_foreign_investor_capital_flow_snpst_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    f.snpst_dt_dim_id,
    f.rpt_log_id,
    f.section_id,
    f.dynamic_row_order,
    f.period_val,
    f.nationality_nm,
    f.investor_nm,
    f.capital_flow_net_val,
    f.src_stm_code,
    submission_cal.cdr_dt AS snpst_cdr_dt,
    f.rpt_code,                   -- [MỚI 2026-10-13] 3 cột cuối khớp ALTER TABLE ADD COLUMN,
    f.rpt_dt_dim_id,
    NULLIF(
        rpt_cal.cdr_dt,
        CAST('1970-01-01' AS DATE)
    ) AS rpt_cdr_dt   -- LEFT JOIN không khớp (DayReport NULL) trả 1970-01-01 khi join_use_nulls=0 → ép về NULL

FROM {{ ref('dtm_fct_foreign_investor_capital_flow_snpst') }} f
JOIN {{ ref('dtm_cdr_dt_dim') }} submission_cal
    ON submission_cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} rpt_cal
    ON rpt_cal.cdr_dt_dim_id = f.rpt_dt_dim_id
WHERE submission_cal.cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')