-- Program code: pttt_fct_macro_indicator_snpst_flat
-- Program name: Flat table Fact Macro Indicator Snapshot
-- Source mart model: dtm_fct_macro_indicator_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per macro indicator per snapshot day
-- Filter: only the snapshot day equal to etl_date
-- Note: This model selects calendar columns from dtm_cdr_dt_dim directly, so it has no snpst_cdr_dt column.
-- Modified: 2026-10-15 add header comment, no logic change
-- Modified: 2026-11-02 tuan.nguyenvanb: them 8 cot ky (period_val, period_year, prev_period_label, prev_period_period_val, prev_period_period_year, prev_year_val, prev_year_label, prev_year_period_year) sau ma_n_val, truoc src_stm_code; flat ghi theo VI TRI cot -> ALTER ADD COLUMN AFTER dung vi tri.
-- Modified: 2026-11-03 tuan.nguyenvanb: them cot unit_tp_code sau indicator_val (flat ghi theo VI TRI cot -> ALTER ADD COLUMN AFTER indicator_val).

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.macro_indicator_code,
    f.macro_indicator_name,
    f.period_tp_code,
    f.period_label,
    f.indicator_val,
    f.unit_tp_code,
    f.prev_period_val,
    f.pct_change,
    f.yoy_pct_change,
    f.ma_n_val,
    f.period_val,
    f.period_year,
    f.prev_period_label,
    f.prev_period_period_val,
    f.prev_period_period_year,
    f.prev_year_val,
    f.prev_year_label,
    f.prev_year_period_year,
    f.src_stm_code,
    cal.cdr_dt,
    cal.year,
    cal.quarter,
    cal.month,
    cal.day_of_week,
    cal.is_weekend,
    cal.holiday_flag,
    cal.is_trading_date
FROM {{ ref('dtm_fct_macro_indicator_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
