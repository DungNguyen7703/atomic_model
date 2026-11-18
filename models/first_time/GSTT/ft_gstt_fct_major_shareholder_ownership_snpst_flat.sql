-- [FIRST-TIME] ft_gstt_fct_major_shareholder_ownership_snpst_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily gstt_fct_major_shareholder_ownership_snpst_flat (config ft_target='gstt_fct_major_shareholder_ownership_snpst_flat', macro macros/first_time).
SELECT /*+ BROADCAST(cal, pc_dim) */
    f.public_company_dim_id,
    f.snpst_dt_dim_id,
    f.ticker_symbol,
    f.major_shareholder_ownership_id,
    f.major_shareholder_nm,
    f.ownership_share_quantity,
    f.ownership_ratio,
    f.closing_ownership_ratio,
    f.ownership_update_dt,
    f.position_code,
    f.src_stm_code,
    f.major_shareholder_identification_nbr,
    f.opening_share_quantity,
    f.opening_ownership_ratio,
    f.opening_balance_dt,
    f.closing_share_quantity,
    f.closing_balance_dt,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS cdr_dt,
    cal.is_trading_date                    AS is_trading_date,
    pc_dim.public_company_nm               AS public_company_nm,
    pc_dim.classification_business_line_nm AS classification_business_line_nm
FROM {{ ft_ref('ft_dtm_fct_major_shareholder_ownership_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
-- [BACKFILL-UAT-ORIG] LEFT JOIN {{ ref('dtm_public_company_dim') }}_hstr pc_dim
LEFT JOIN {{ ref('dtm_public_company_dim') }} pc_dim   -- [BACKFILL-UAT-NEW]
    ON pc_dim.public_company_dim_id = f.public_company_dim_id
    -- [BACKFILL-UAT-ORIG] AND pc_dim.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    AND pc_dim.ds_rcrd_st = 'ACTIVE'
-- [BACKFILL-UAT-ORIG] WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] [BACKFILL-UAT-ONEPASS-GSTT] TAM THOI bo loc WHERE theo etl_date de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
