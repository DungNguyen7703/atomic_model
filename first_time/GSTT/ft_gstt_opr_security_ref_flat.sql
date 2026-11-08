-- [FIRST-TIME] ft_gstt_opr_security_ref_flat: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily gstt_opr_security_ref_flat (config ft_target='gstt_opr_security_ref_flat', macro macros/first_time).
-- ────────────────────────────────────────────────────────────
-- Model : gstt_opr_security_ref_flat
-- Type  : OPERATIONAL
-- 2026-10-09 tuan.nguyenvanb: [MOI, LLD v4.42 DTM_GSTT_opr_security_ref_MDDS_JAD_STOCKINFOR] Flat Operational Security Reference
-- (ma CK, 1 dong / symbol, current-state). Chi lay ban ghi ACTIVE cua snapshot etl_date (mart scd4a giu ca ban ghi INACTIVE trong _hstr).
-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] first_time: doc bang scd4a tu bang MAIN thay vi <bang>_hstr. [BACKFILL-UAT-NEW]
-- 2026-10-12 tuan.nguyenvanb: [FIRST-TIME] Doc toan bo snapshot theo ngay trong _hstr (mart chay ft_hstr_by_day), ghi ClickHouse
-- moi ngay 1 partition (ft_ck_by_day, ft_day_column=ds_snpst_dt). Chi lay ban ghi ACTIVE.
-- ────────────────────────────────────────────────────────────

SELECT
    o.symbol,
    o.security_full_nm,   -- [2026-10-16 LLD v4.49]
    o.isin_code,
    o.as_of_dt,
    o.stock_tp_code,
    o.floor_code,
    o.derivative_product_nm,
    o.security_class_nm,
    o.industry_code,
    o.industry_nm,
    o.src_stm_code,
    o.ds_snpst_dt   -- [FIRST-TIME 2026-10-12] ngay snapshot (ft_ck_by_day, ft_day_column=ds_snpst_dt)

-- [BACKFILL-UAT-ORIG] FROM {{ ft_ref('ft_dtm_opr_security_ref') }}_hstr o
-- [BACKFILL-UAT-NEW 2026-10-09] FROM {{ ft_ref('ft_dtm_opr_security_ref') }} o
FROM {{ ft_ref('ft_dtm_opr_security_ref') }}_hstr o   -- [FIRST-TIME 2026-10-12] doc MOI snapshot ngay trong _hstr
-- [BACKFILL-UAT-ORIG] WHERE o.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  -- [BACKFILL-UAT-ORIG] AND o.ds_rcrd_st = 'ACTIVE'
WHERE o.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW]
