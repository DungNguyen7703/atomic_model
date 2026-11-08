-- [FIRST-TIME] ft_pttt_fct_securities_company_balance_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily pttt_fct_securities_company_balance_snpst_flat (config ft_target='pttt_fct_securities_company_balance_snpst_flat', macro macros/first_time).
-- 2026-10-28 tuan.nguyenvanb: [FIRST-TIME PTTT] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that), GIU loc f.ds_snpst_dt = etl_date (lat first-time duy nhat, ds_snpst_dt = etl_date)
-- de khong doc cac lat daily cu trong bang that. Dim doc bang MAIN, KHONG loc ACTIVE (giong daily). ft_ck_by_day + ft_day_column=ds_snpst_dt: model tra san cot ds_snpst_dt
-- (cuoi SELECT) nen macro khong them lan nua. HAN CHE: khai thac lay max(ds_snpst_dt) <= ngay chon -> ngay chon truoc etl_date cua lat se khong co du lieu.

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.securities_company_dim_id,
    f.rpt_year,
    f.rpt_quarter,
    f.total_liabilities_amt,
    f.owner_equity_amt,
    f.src_stm_code,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    sc.sc_code,
    sc.sc_nm,
    f.ds_snpst_dt AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] lat first-time = etl_date (ft_day_column)
FROM {{ ft_ref('ft_dtm_fct_securities_company_balance_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_securities_company_dim') }} sc   -- [BACKFILL-UAT-NEW] bang MAIN
    ON sc.securities_company_dim_id = f.securities_company_dim_id
-- [BACKFILL-UAT-ORIG] LEFT JOIN {{ ref('dtm_securities_company_dim') }}_hstr sc ... AND sc.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
WHERE f.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
