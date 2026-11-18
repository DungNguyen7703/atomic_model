-- ────────────────────────────────────────────────────────────
-- Model : tt_opr_examination_case_list_flat
-- Type  : OPERATIONAL
-- Sua 2026-11-03 [LLD O_TT_25]: them cot violation_behavior_nm (sau decision_year, truoc src_stm_code) - ck_snapshot
-- insert theo VI TRI -> ALTER ADD COLUMN ... AFTER decision_year (xem scratch/alter_tt_lld_20261103.sql).
-- ────────────────────────────────────────────────────────────

SELECT
    o.examination_team_target_code,
    o.examination_team_code,
    o.target_nm,
    o.target_tp_code,
    o.form_tp_code,
    o.status_code,
    o.decision_dt,
    o.decision_year,
    o.violation_behavior_nm,
    o.src_stm_code

FROM {{ ref('dtm_opr_examination_case_list') }}_hstr o
WHERE o.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND o.ds_rcrd_st = 'ACTIVE'  -- 2026-09-29: loai ban ghi INACTIVE (da xoa o nguon) scd4a giu lai trong _hstr