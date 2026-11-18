-- ────────────────────────────────────────────────────────────
-- Model : gstt_opr_security_ref_flat
-- Type  : OPERATIONAL
-- 2026-10-09 tuan.nguyenvanb: [MOI, LLD v4.42 DTM_GSTT_opr_security_ref_MDDS_JAD_STOCKINFOR] Flat Operational Security Reference
-- (ma CK, 1 dong / symbol, current-state). Chi lay ban ghi ACTIVE cua snapshot etl_date (mart scd4a giu ca ban ghi INACTIVE trong _hstr).
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
    o.src_stm_code

FROM {{ ref('dtm_opr_security_ref') }}_hstr o
WHERE o.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND o.ds_rcrd_st = 'ACTIVE'
