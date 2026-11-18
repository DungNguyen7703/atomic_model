-- ────────────────────────────────────────────────────────────
-- Model : nhnck_opr_practitioner_violation_hist_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

WITH src AS (
    SELECT
        practitioner_code,
        conduct_violation_code,
        violation_tp_code,
        violation_tp_nm,
        note,
        violation_status_code,
        violation_status_nm,
        decision_nbr,
        decision_signed_dt,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_violation_hist') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    practitioner_code,
    conduct_violation_code,
    violation_tp_code,
    violation_tp_nm,
    note,
    violation_status_code,
    violation_status_nm,
    decision_nbr,
    decision_signed_dt,
    src_stm_code

FROM src 