-- ────────────────────────────────────────────────────────────
-- Model : tt_fct_inspection_team_activity_flat
-- Type  : FACT
-- Sua 2026-08-18: WHERE f.ds_snpst_dt -> f.data_dt; strategy doi sang
-- ck_event -> passthrough f.data_dt lam cot partition.
-- Sua 2026-09-28 [LLD moi]: mart doi ten calendar_dt_dim_id ->
-- decision_dt_dim_id, them 2 cot FK (decision_dt_dim_id, inspection_team_
-- dim_id) truoc block CALENDAR DATE DIMENSION - dung ADD COLUMN ...
-- AFTER cho dung vi tri (ck_event insert theo VI TRI, xem DDL kem theo).
-- content KHONG bi xoa o Inspection Team (chi Examination Team bi xoa).
-- Sua 2026-10-25 [DESIGN tra loi, BA chot]: bo cot content (atomic inspection_team bo content) - CAN ALTER TABLE ... DROP COLUMN content o ClickHouse.
-- ────────────────────────────────────────────────────────────

SELECT
    f.decision_dt_dim_id,
    f.inspection_team_dim_id,
    date_format(to_date(f.decision_dt_dim_id, 'yyyyMMdd'), 'yyyy-MM-dd')                         AS cdr_dt,
    dim.inspection_team_code,
    dim.start_dt,
    dim.end_dt,
    dim.effective_start_dt,
    dim.effective_end_dt,
    dim.src_stm_code                    AS inspection_team_src_stm_code,
    f.data_dt                           AS data_dt

FROM {{ ref('dtm_fct_inspection_team_activity') }} f
JOIN {{ ref('dtm_inspection_team_dim') }}_hstr dim
    ON dim.inspection_team_dim_id = f.inspection_team_dim_id AND dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE f.data_dt = '{{ var("etl_date") }}'
