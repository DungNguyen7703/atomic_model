/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_practitioner_license_certificate_snpst
* Program name: Dtm Fct Practitioner License Certificate Snpst
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH certificate_document AS (
    SELECT
        sp_license_certificate_document_code,
        certificate_nbr,
        sp_license_certificate_tp_code,
        revocation_dt,
        status_code,
        sp_license_certificate_document_id,
        issue_sp_license_decision_document_id,
        revocation_sp_license_decision_document_id, 
        cancellation_sp_license_decision_document_id, 
        sp_code,
        issue_dt
    FROM {{ ref('atm_sp_license_certificate_document') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_CERTIFICATE_RECORDS'
),

decision_document AS (
    SELECT
        decision_tp_code,
        decision_signed_dt,
        sp_license_decision_document_id
    FROM {{ ref('atm_sp_license_decision_document') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_DECISIONS'
),

practitioner AS (
    SELECT 
        securities_practitioner_dim_id, 
        practitioner_code
    FROM {{ ref('dtm_securities_practitioner_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

certificate_type AS (
    SELECT 
        certificate_tp_dim_id,
        certificate_tp_code 
    FROM {{ ref('dtm_sp_license_certificate_type_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_CERTIFICATES'
)

SELECT
    CAST(practitioner.securities_practitioner_dim_id AS string)                                            AS practitioner_dim_id,
    CAST(date_format(certificate_document.issue_dt, 'yyyyMMdd') AS string)                                 AS issue_dt_dim_id,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')                                 AS snpst_dt_dim_id,
    CAST(certificate_type.certificate_tp_dim_id AS string)                                                 AS certificate_tp_dim_id,
    CAST(certificate_document.sp_license_certificate_document_code AS string)                              AS license_certificate_document_code,
    CAST(certificate_document.certificate_nbr AS string)                                                   AS certificate_nbr,
    CAST(CASE WHEN decision_document.decision_tp_code = '3' THEN 'Y' 
              WHEN decision_document.decision_tp_code = '1' THEN 'N' 
              ELSE NULL END AS string)                                                                     AS is_reissue_indicator,
    CAST(certificate_document.issue_dt AS date)                                                            AS certificate_issue_dt,
    CAST(certificate_document.revocation_dt AS date)                                                       AS revocation_dt,
    CAST(COALESCE(decision_document_2.decision_tp_code, decision_document_3.decision_tp_code) AS string)   AS decision_tp_code,
    CAST(COALESCE(decision_document_2.decision_signed_dt, decision_document_3.decision_signed_dt) AS date) AS decision_signed_dt,
    CAST(certificate_document.status_code AS string)                                                       AS certificate_status_code
FROM certificate_document
LEFT JOIN decision_document
    ON  decision_document.sp_license_decision_document_id = certificate_document.issue_sp_license_decision_document_id
LEFT JOIN decision_document AS decision_document_2
    ON  decision_document_2.sp_license_decision_document_id = certificate_document.revocation_sp_license_decision_document_id
LEFT JOIN decision_document AS decision_document_3
    ON  decision_document_3.sp_license_decision_document_id = certificate_document.cancellation_sp_license_decision_document_id
LEFT JOIN practitioner
    ON  practitioner.practitioner_code = certificate_document.sp_code
LEFT JOIN certificate_type
    ON  certificate_type.certificate_tp_code = certificate_document.sp_license_certificate_tp_code
