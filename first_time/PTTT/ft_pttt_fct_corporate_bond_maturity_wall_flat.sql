-- [FIRST-TIME] ft_pttt_fct_corporate_bond_maturity_wall_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily pttt_fct_corporate_bond_maturity_wall_flat (config ft_target='pttt_fct_corporate_bond_maturity_wall_flat', macro macros/first_time).
-- 2026-10-28 tuan.nguyenvanb: [FIRST-TIME PTTT] Ban khoi tao: doc fact tu ban ft_ (ft_ref -> bang that), BO loc data_dt = etl_date de nap toan bo lich su 1 lan.
-- Daily: ds_snpst_dt cua flat = etl_date = data_dt cua lat (snpst_cdr_dt la NGAY CHOT QUY, khong phai ngay chay) -> ban ft tra san cot ds_snpst_dt = data_dt o CUOI SELECT
-- va ft_day_column = ds_snpst_dt (macro khong them lan nua), de moi lat daily (data_dt) = 1 partition ClickHouse nhu daily.
-- Thuoc tinh chung khoan (symbol, listed_share_count, total_listing_vol, symbol_status_code...) doc dtm_securities_dim_hstr dung ngay data_dt (ACTIVE), khong doc MAIN.

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.securities_dim_id,
    f.ranking_code,
    f.bond_flow_code,
    f.bond_code,
    f.par_val,
    f.outstanding_vol,
    f.bond_outstanding_val,
    f.maturity_dt,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt,
    se_dim.symbol,
    se_dim.security_full_nm,
    se_dim.stock_tp_code,
    se_dim.floor_code,
    se_dim.listed_share_count,
    se_dim.total_listing_vol,
    se_dim.underlying_symbol,
    se_dim.issuer_nm,
    se_dim.listing_dt,
    se_dim.symbol_status_code,
    CAST(f.data_dt AS date) AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = data_dt (= etl_date cua daily); cot nay thay cho ds_snpst_dt ma ft_ck_by_day tu gan
FROM {{ ft_ref('ft_dtm_fct_corporate_bond_maturity_wall') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
LEFT JOIN {{ ft_ref('ft_dtm_securities_dim') }}_hstr se_dim   -- [BACKFILL-UAT-NEW] _hstr theo ngay data_dt (daily doc MAIN tai etl_date)
    ON se_dim.securities_dim_id = f.securities_dim_id
    AND se_dim.ds_snpst_dt = CAST(f.data_dt AS date)
    AND se_dim.ds_rcrd_st = 'ACTIVE'
-- [BACKFILL-UAT-ORIG] WHERE f.data_dt = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyy-MM-dd')
