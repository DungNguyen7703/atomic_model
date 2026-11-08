-- ────────────────────────────────────────────────────────────
-- Model : qlcb_fct_tthc_ap_document_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    f.ap_document_id,
    CAST(f.submission_tms AS DATE) AS submission_dt,
    f.document_status_group_nm,
    f.offering_method_nm
FROM {{ ref('dtm_fct_tthc_ap_document') }} f
WHERE f.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
