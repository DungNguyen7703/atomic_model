-- ────────────────────────────────────────────────────────────
-- Model : tt_opr_penalty_decision_list_flat
-- Type  : OPERATIONAL
-- Sua 2026-11-03 [LLD O_TT_25]: them cot violation_behavior_nm (sau total_fine_amt, truoc src_stm_code) - ck_snapshot
-- insert theo VI TRI -> ALTER ADD COLUMN ... AFTER total_fine_amt (xem scratch/alter_tt_lld_20261103.sql).
-- ────────────────────────────────────────────────────────────

SELECT
    o.pd_subject_code,
    o.violation_case_code,
    o.subject_nm,
    o.subject_tp_code,
    o.form_tp_code,
    o.life_cycle_status_code,
    o.issued_dt,
    o.issued_year,
    o.total_fine_amt,
    o.violation_behavior_nm,
    o.src_stm_code

FROM {{ ref('dtm_opr_penalty_decision_list') }}_hstr o
WHERE o.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND o.ds_rcrd_st = 'ACTIVE'  -- 2026-09-29: loai ban ghi INACTIVE (da xoa o nguon) scd4a giu lai trong _hstr