-- ────────────────────────────────────────────────────────────
-- Model : tt_fct_penalty_decision_subject_behavior_flat
-- Type  : FACT
-- Sua 2026-08-18:
--   1) WHERE f.ds_snpst_dt -> f.data_dt; strategy doi sang ck_event ->
--      passthrough f.data_dt lam cot partition.
--   2) JOIN behavior_dim, subject_dim: INNER -> LEFT JOIN, vi mart
--      dtm_fct_penalty_decision_subject_behavior da dao chieu driving
--      table sang penalty_decision (LEFT JOIN xuong subject/subject_behavior)
--      de QD khong co Subject/Subject Behavior van co mat tren Fact ->
--      f.penalty_decision_subject_behavior_dim_id / f.penalty_decision_subject_dim_id
--      gio co the NULL. JOIN toi decision_dim giu nguyen INNER vi
--      f.penalty_decision_dim_id luon resolve duoc sau fix mart.
--   3) Sua 2026-09-28 [LLD moi]: mart doi ten calendar_dt_dim_id ->
--      issued_dt_dim_id, them 4 cot FK truoc applied_fine_amt - dung ADD
--      COLUMN ... AFTER cho dung vi tri (ck_event insert theo VI TRI,
--      xem DDL kem theo).
--   4) Sua 2026-10-01 [LLD 2026-10-01, Dev #1: 1 QD co the xu phat NHIEU hanh vi - K_TT_46/47 dem
--      QD theo TUNG nhom hanh vi]: them cot violation_behavior_group_nm - lay thang tu
--      f.violation_behavior_group_nm cua mart (COALESCE ten hanh vi theo dong, fallback ten dai
--      dien QD). Dat o CUOI (sau data_dt, truoc ds_etl_pcs_tms do macro tu them) theo flat DDL
--      cua design -> ALTER ADD COLUMN ... AFTER data_dt (scratch/alter_tt_lld_20261001.sql).
--      Cot violation_behavior_nm (1 ten dai dien / QD) GIU NGUYEN cho Nhom 20 (K_TT_70-84).
-- ────────────────────────────────────────────────────────────

SELECT
    f.issued_dt_dim_id,
    f.penalty_decision_subject_behavior_dim_id,
    f.penalty_decision_dim_id,
    f.penalty_decision_subject_dim_id,
    f.applied_fine_amt,
    date_format(to_date(f.issued_dt_dim_id, 'yyyyMMdd'), 'yyyy-MM-dd')                          AS cdr_dt,
    behavior_dim.penalty_decision_subject_behavior_code,
    decision_dim.violation_behavior_nm,
    behavior_dim.src_stm_code           AS penalty_decision_subject_behavior_src_stm_code,
    decision_dim.penalty_decision_code,
    decision_dim.src_stm_code           AS penalty_decision_src_stm_code,
    subject_dim.penalty_decision_subject_code,
    subject_dim.subject_tp_code,
    subject_dim.src_stm_code            AS penalty_decision_subject_src_stm_code,
    f.data_dt                           AS data_dt,
    f.violation_behavior_group_nm       AS violation_behavior_group_nm

FROM {{ ref('dtm_fct_penalty_decision_subject_behavior') }} f
LEFT JOIN {{ ref('dtm_penalty_decision_subject_behavior_dim') }}_hstr behavior_dim
    ON behavior_dim.penalty_decision_subject_behavior_dim_id = f.penalty_decision_subject_behavior_dim_id AND behavior_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
LEFT JOIN {{ ref('dtm_penalty_decision_dim') }}_hstr decision_dim
    ON decision_dim.penalty_decision_dim_id = f.penalty_decision_dim_id AND decision_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
LEFT JOIN {{ ref('dtm_penalty_decision_subject_dim') }}_hstr subject_dim
    ON subject_dim.penalty_decision_subject_dim_id = f.penalty_decision_subject_dim_id AND subject_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE f.data_dt = '{{ var("etl_date") }}'
