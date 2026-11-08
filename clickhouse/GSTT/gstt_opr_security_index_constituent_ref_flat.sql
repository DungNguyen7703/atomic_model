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
-- 2026-10-09 tuan.nguyenvanb: [LLD v4.42, tach bang] BO 6 cot ma CK (stock_tp_code, stock_floor_code, derivative_product_nm,
-- security_class_code, industry_code, industry_nm) - chuyen sang gstt_opr_security_ref_flat. Model ck_snapshot insert theo VI TRI
-- nen bang ClickHouse that phai DROP COLUMN 6 cot nay (xem scratch/alter_gstt_security_ref_20261009.sql).
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
    o.src_stm_code

FROM {{ ref('dtm_opr_security_index_constituent_ref') }}_hstr o
WHERE o.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND o.ds_rcrd_st = 'ACTIVE'
