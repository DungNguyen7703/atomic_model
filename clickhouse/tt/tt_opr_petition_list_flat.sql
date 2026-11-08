-- ────────────────────────────────────────────────────────────
-- Model : tt_opr_petition_list_flat
-- Type  : OPERATIONAL
-- Sua 2026-09-29: mart dtm_opr_petition_list doi unique_key sang
-- petition_id (giu ca cac don xin petition_code=NULL, theo yeu cau BA) -
-- them petition_id vao flat. Model la ck_snapshot (insert theo VI TRI cot,
-- giong append/ck_event) - dat petition_id o DAU, dung ADD COLUMN ... FIRST
-- ben ClickHouse cho khop vi tri (xem DDL kem theo).
-- ────────────────────────────────────────────────────────────

SELECT
    o.petition_id,
    o.petition_code,
    o.petition_category_code,
    o.content,
    o.target_nm,
    o.life_cycle_status_code,
    o.received_dt,
    o.received_year,
    o.src_stm_code

FROM {{ ref('dtm_opr_petition_list') }}_hstr o
WHERE o.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND o.ds_rcrd_st = 'ACTIVE'  -- 2026-09-29: loai ban ghi INACTIVE (da xoa o nguon) scd4a giu lai trong _hstr