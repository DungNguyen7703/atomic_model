-- ────────────────────────────────────────────────────────────
-- Model : tt_fct_penalty_decision_subject_flat
-- Type  : FACT
-- Sua 2026-08-18: WHERE f.ds_snpst_dt -> f.data_dt; strategy doi sang
-- ck_event -> passthrough f.data_dt lam cot partition.
-- Sua 2026-09-28 [LLD moi]: mart doi ten calendar_dt_dim_id ->
-- issued_dt_dim_id, them 3 cot FK truoc block CALENDAR DATE DIMENSION -
-- dung ADD COLUMN ... AFTER cho dung vi tri (ck_event insert theo VI
-- TRI, xem DDL kem theo).
-- ────────────────────────────────────────────────────────────

SELECT
    f.issued_dt_dim_id,
    f.penalty_decision_subject_dim_id,
    f.penalty_decision_dim_id,
    date_format(to_date(f.issued_dt_dim_id, 'yyyyMMdd'), 'yyyy-MM-dd')                        AS cdr_dt,
    subject_dim.penalty_decision_subject_code,
    subject_dim.subject_tp_code,
    subject_dim.src_stm_code            AS penalty_decision_subject_src_stm_code,
    decision_dim.penalty_decision_code,
    decision_dim.src_stm_code           AS penalty_decision_src_stm_code,
    f.data_dt                           AS data_dt

FROM {{ ref('dtm_fct_penalty_decision_subject') }} f
LEFT JOIN {{ ref('dtm_penalty_decision_subject_dim') }}_hstr subject_dim
    ON subject_dim.penalty_decision_subject_dim_id = f.penalty_decision_subject_dim_id AND subject_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
JOIN {{ ref('dtm_penalty_decision_dim') }}_hstr decision_dim
    ON decision_dim.penalty_decision_dim_id = f.penalty_decision_dim_id AND decision_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE f.data_dt = '{{ var("etl_date") }}'
