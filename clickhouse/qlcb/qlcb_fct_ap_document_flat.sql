-- ────────────────────────────────────────────────────────────
-- Model : qlcb_fct_tthc_ap_document_flat
-- Type  : FACT
-- ────────────────────────────────────────────────────────────

SELECT
    f.ap_document_code,
    f.ap_document_applicant_nm,
    f.securities_code,
    f.offering_method_nm,
    f.submission_dt,
    f.document_status_group_nm
FROM {{ ref('dtm_fct_ap_document') }} f
WHERE f.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
