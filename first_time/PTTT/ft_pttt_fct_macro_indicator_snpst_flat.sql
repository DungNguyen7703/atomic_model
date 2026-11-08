-- [FIRST-TIME] ft_pttt_fct_macro_indicator_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily pttt_fct_macro_indicator_snpst_flat (config ft_target='pttt_fct_macro_indicator_snpst_flat', macro macros/first_time).
-- 2026-10-28 tuan.nguyenvanb: [FIRST-TIME PTTT] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that) va BO loc snpst_dt_dim_id theo ngay chay de nap toan bo
-- lich su trong 1 lan; strategy ft_ck_by_day gan ds_snpst_dt = cdr_dt (ft_day_column, flat nay khong co cot snpst_cdr_dt) -> 1 partition = 1 ngay nhu daily.
-- 2026-11-02 tuan.nguyenvanb: them 8 cot ky giong ban daily (sau ma_n_val, truoc src_stm_code).
-- 2026-11-03 tuan.nguyenvanb: them cot unit_tp_code sau indicator_val (flat ghi theo VI TRI cot -> ALTER ADD COLUMN AFTER indicator_val).

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
FROM {{ ft_ref('ft_dtm_fct_macro_indicator_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [BACKFILL-UAT-ORIG] WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
