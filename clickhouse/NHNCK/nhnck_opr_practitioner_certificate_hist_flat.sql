-- ────────────────────────────────────────────────────────────
-- Model : nhnck_opr_practitioner_certificate_hist_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

WITH src AS (
    SELECT
        practitioner_code,
        license_certificate_document_code,
        certificate_nbr,
        certificate_tp_code,
        certificate_tp_nm,
        issue_dt,
        revocation_dt,
        issue_decision_nbr,
        revocation_decision_nbr,
        certificate_status_code,
        certificate_status_nm,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_certificate_hist') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    practitioner_code,
    license_certificate_document_code,
    certificate_nbr,
    certificate_tp_code,
    certificate_tp_nm,
    issue_dt,
    revocation_dt,
    issue_decision_nbr,
    revocation_decision_nbr,
    certificate_status_code,
    certificate_status_nm,
    src_stm_code

FROM src