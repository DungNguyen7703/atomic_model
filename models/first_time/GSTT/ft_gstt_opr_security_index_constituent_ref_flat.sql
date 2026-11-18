-- [FIRST-TIME] ft_gstt_opr_security_index_constituent_ref_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily gstt_opr_security_index_constituent_ref_flat (config ft_target='gstt_opr_security_index_constituent_ref_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : gstt_opr_security_index_constituent_ref_flat
-- Type  : OPERATIONAL
-- 2026-10-06 tuan.nguyenvanb: [MOI, LLD DTM_GSTT_opr_security_index_constituent_ref_MDDS_JAD_CSIDXINFOR,
-- GSTT Nhom 44/45] Flat Operational Security Index Constituent Reference (Index Code <-> Symbol <->
-- ISIN Code). Operational/current-state: chi lay ban ghi ACTIVE cua snapshot etl_date (mart scd4a
-- giu ca ban ghi INACTIVE trong _hstr).
-- 2026-10-08 tuan.nguyenvanb: [LLD b6c83b76, bo sung cot] Them 8 cot tu mart: index_constituent_snpst_code,
-- index_id (ngay sau symbol), stock_tp_code, stock_floor_code, derivative_product_nm, security_class_code,
-- industry_code, industry_nm (ngay sau as_of_dt, truoc src_stm_code). Model la ck_snapshot - insert theo
-- VI TRI cot nen bang ClickHouse that phai ADD COLUMN ... AFTER dung cac vi tri nay. Thu tu cot cua cac cot
-- co san KHONG doi (isin_code van dung sau index_id - khac thu tu DDL mau trong repo design).
-- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
-- Dong goc giu o dang comment BACKFILL-UAT-ORIG. Revert: bo comment BACKFILL-UAT-ORIG va xoa dong BACKFILL-UAT-NEW (hoac chuyen che do daily bang first_time_mode.py). [BACKFILL-UAT-NEW]
-- 2026-10-09 tuan.nguyenvanb: [LLD v4.42, tach bang] BO 6 cot ma CK (stock_tp_code, stock_floor_code, derivative_product_nm,
-- security_class_code, industry_code, industry_nm) - chuyen sang gstt_opr_security_ref_flat. Model ck_snapshot insert theo VI TRI
-- nen bang ClickHouse that phai DROP COLUMN 6 cot nay (xem scratch/alter_gstt_security_ref_20261009.sql).
-- 2026-10-12 tuan.nguyenvanb: [FIRST-TIME] Doc toan bo snapshot theo ngay trong _hstr (mart chay ft_hstr_by_day), ghi ClickHouse
-- moi ngay 1 partition (ft_ck_by_day, ft_day_column=ds_snpst_dt). Chi lay ban ghi ACTIVE.
-- ────────────────────────────────────────────────────────────

SELECT
    o.index_code,
    o.symbol,
    o.index_constituent_snpst_code,
    o.index_id,
    o.isin_code,
    o.index_nm,
    o.floor_code,
    o.add_dt,
    o.as_of_dt,
    o.src_stm_code,
    o.ds_snpst_dt   -- [FIRST-TIME 2026-10-12] ngay snapshot (ft_ck_by_day, ft_day_column=ds_snpst_dt)

-- [BACKFILL-UAT-ORIG] FROM {{ ft_ref('ft_dtm_opr_security_index_constituent_ref') }}_hstr o
-- [BACKFILL-UAT-NEW 2026-10-09] FROM {{ ft_ref('ft_dtm_opr_security_index_constituent_ref') }} o
FROM {{ ft_ref('ft_dtm_opr_security_index_constituent_ref') }}_hstr o   -- [FIRST-TIME 2026-10-12] doc MOI snapshot ngay trong _hstr
-- [BACKFILL-UAT-ORIG] WHERE o.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  -- [BACKFILL-UAT-ORIG] AND o.ds_rcrd_st = 'ACTIVE'
WHERE o.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
