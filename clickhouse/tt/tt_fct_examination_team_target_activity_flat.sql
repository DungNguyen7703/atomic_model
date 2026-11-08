-- ────────────────────────────────────────────────────────────
-- Model : tt_fct_examination_team_target_activity_flat
-- Type  : FACT
-- Sua 2026-08-18: WHERE f.ds_snpst_dt -> f.data_dt; strategy doi sang
-- ck_event -> passthrough f.data_dt lam cot partition.
-- Sua 2026-09-28 [LLD moi]: mart doi ten calendar_dt_dim_id ->
-- decision_dt_dim_id, them 3 cot FK truoc block CALENDAR DATE DIMENSION
-- - dung ADD COLUMN ... AFTER cho dung vi tri (ck_event insert theo VI
-- TRI, xem DDL kem theo). Bo cot content (LLD xoa attribute nay khoi
-- Examination Team Dimension).
-- ────────────────────────────────────────────────────────────

SELECT
    f.decision_dt_dim_id,
    f.examination_team_target_dim_id,
    f.examination_team_dim_id,
    date_format(to_date(f.decision_dt_dim_id, 'yyyyMMdd'), 'yyyy-MM-dd')                           AS cdr_dt,
    target_dim.examination_team_target_code,
    target_dim.target_tp_code,
    target_dim.src_stm_code             AS examination_team_target_src_stm_code,
    team_dim.examination_team_code,
    team_dim.start_dt,
    team_dim.end_dt,
    team_dim.effective_start_dt,
    team_dim.effective_end_dt,
    team_dim.src_stm_code               AS examination_team_src_stm_code,
    f.data_dt                           AS data_dt

FROM {{ ref('dtm_fct_examination_team_target_activity') }} f
JOIN {{ ref('dtm_examination_team_target_dim') }}_hstr target_dim
    ON target_dim.examination_team_target_dim_id = f.examination_team_target_dim_id AND target_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
JOIN {{ ref('dtm_examination_team_dim') }}_hstr team_dim
    ON team_dim.examination_team_dim_id = f.examination_team_dim_id AND team_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE f.data_dt = '{{ var("etl_date") }}'
