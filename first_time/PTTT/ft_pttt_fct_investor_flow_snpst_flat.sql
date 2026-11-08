-- [FIRST-TIME] ft_pttt_fct_investor_flow_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily pttt_fct_investor_flow_snpst_flat (config ft_target='pttt_fct_investor_flow_snpst_flat', macro macros/first_time).
-- 2026-10-28 tuan.nguyenvanb: [FIRST-TIME PTTT] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that) va BO loc snpst_dt_dim_id theo ngay chay de nap toan bo
-- lich su trong 1 lan; strategy ft_ck_by_day gan ds_snpst_dt = snpst_cdr_dt (ft_day_column) -> 1 partition = 1 ngay nhu daily.

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.investor_group_dim_id,
    f.buy_val,
    f.sell_val,
    f.net_flow_val,
    f.trading_val_ratio,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    ig.investor_group_code,
    ig.investor_group_nm
FROM {{ ft_ref('ft_dtm_fct_investor_flow_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_investor_group_dim') }} ig
    ON ig.investor_group_dim_id = f.investor_group_dim_id
-- [BACKFILL-UAT-ORIG] WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
