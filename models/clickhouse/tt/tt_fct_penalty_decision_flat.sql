-- ────────────────────────────────────────────────────────────
-- Model : tt_fct_penalty_decision_flat
-- Type  : FACT
-- Sua 2026-08-18: WHERE f.ds_snpst_dt -> f.data_dt; strategy doi sang
-- ck_event -> passthrough f.data_dt lam cot partition.
-- Sua 2026-09-28 [LLD moi]: mart doi ten calendar_dt_dim_id ->
-- issued_dt_dim_id, them 2 cot FK (issued_dt_dim_id, penalty_decision_
-- dim_id) va measure moi paid_fine_amt (SUM tu Penalty Decision Subject)
-- - dung ADD COLUMN ... AFTER cho dung vi tri (ck_event insert theo VI
-- TRI, xem DDL kem theo).
-- ────────────────────────────────────────────────────────────

SELECT
    f.issued_dt_dim_id,
    f.penalty_decision_dim_id,
    f.total_fine_amt,
    f.paid_fine_amt,
    date_format(to_date(f.issued_dt_dim_id, 'yyyyMMdd'), 'yyyy-MM-dd')                        AS cdr_dt,
    dim.penalty_decision_code,
    dim.src_stm_code                    AS penalty_decision_src_stm_code,
    f.data_dt                           AS data_dt

FROM {{ ref('dtm_fct_penalty_decision') }} f
JOIN {{ ref('dtm_penalty_decision_dim') }}_hstr dim
    ON dim.penalty_decision_dim_id = f.penalty_decision_dim_id AND dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE f.data_dt = '{{ var("etl_date") }}'
