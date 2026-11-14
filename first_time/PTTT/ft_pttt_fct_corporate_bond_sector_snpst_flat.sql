-- [FIRST-TIME] ft_pttt_fct_corporate_bond_sector_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily pttt_fct_corporate_bond_sector_snpst_flat (config ft_target='pttt_fct_corporate_bond_sector_snpst_flat', macro macros/first_time).
-- 2026-10-28 tuan.nguyenvanb: [FIRST-TIME PTTT] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that) va BO loc snpst_dt_dim_id theo ngay chay de nap toan bo
-- lich su trong 1 lan; strategy ft_ck_by_day gan ds_snpst_dt = snpst_cdr_dt (ft_day_column) -> 1 partition = 1 ngay nhu daily.

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.corp_bond_industry_dim_id,
    f.bond_outstanding_val,
    f.bond_outstanding_val_total,
    f.bond_outstanding_ratio,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    COALESCE(cbi.industry_code, 'NA')                  AS industry_code,
    COALESCE(cbi.industry_nm, 'Chưa phân ngành')       AS industry_nm   -- [2026-11-10] trai phieu chua phan nganh (dim NULL) -> 1 dong "Chua phan nganh"
FROM {{ ft_ref('ft_dtm_fct_corporate_bond_sector_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ref('dtm_corp_bond_industry_dim') }} cbi
    ON cbi.corp_bond_industry_dim_id = f.corp_bond_industry_dim_id
    AND cbi.src_stm_code = 'IDS_CATEGORIES'  -- [2026-10-29] tranh nhan dong do ban ghi dim tu nguon cu
-- [BACKFILL-UAT-ORIG] WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
