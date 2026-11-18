
-- ────────────────────────────────────────────────────────────
-- Model : qlcb_fct_tthc_ap_document_stat_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    f.offering_method_nm,
    CAST(f.submission_tms AS DATE) AS submission_dt,
    f.registered_document_cnt,
    f.processing_document_cnt,
    f.approved_document_cnt,
    f.rejected_document_cnt,
    f.total_document_cnt
FROM {{ ref('dtm_fct_tthc_ap_document_stat') }} f
WHERE f.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
