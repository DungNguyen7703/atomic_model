-- [FIRST-TIME] ft_pttt_fct_domestic_institution_net_trade_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily pttt_fct_domestic_institution_net_trade_snpst_flat (config ft_target, macro macros/first_time).
-- 2026-11-06 tuan.nguyenvanb: [FIRST-TIME PTTT] doc fact tu ban ft_ (ft_ref), BO loc snpst_dt_dim_id theo ngay chay; ft_ck_by_day gan ds_snpst_dt = snpst_cdr_dt.

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.security_symbol_code,
    f.domestic_institution_buy_val,
    f.domestic_institution_sell_val,
    f.domestic_institution_net_val,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt
FROM {{ ft_ref('ft_dtm_fct_domestic_institution_net_trade_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [BACKFILL-UAT-ORIG] WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
