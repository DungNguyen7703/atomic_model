/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_certificate_hist
* Program name: Dtm Opr Practitioner Certificate Hist
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-11        Duc                certificate_nbr => lấy từ sp_license_certificate_document.certificate_nbr, bỏ organization_report
* 2026-10-22        nguyet.do          BA cập nhật: certificate_status_code lấy CERTIFICATE_RECORDS.STATUS
*                                       (sp_license_certificate_document.status_code) thay cho NEW_STATUS
*                                       bản ghi lịch sử mới nhất; bỏ CTE certificate_status_history
* 2026-11-03        claude             Đồng bộ LLD 8810cebe: certificate_status_code quay lại lấy
*                                       new_certificate_status_code của bản ghi lịch sử đổi trạng thái mới nhất
*                                       (atm_sp_license_certificate_status_change_history, src
*                                       NHNCK_CERTIFICATE_RECORD_STATUS_HISTORIES) — ROW_NUMBER theo
*                                       data_dt DESC, CAST(history_code AS BIGINT) DESC. Đảo lại thay đổi 2026-10-22
*                                       (đã lấy sp_license_certificate_document.status_code) theo LLD hiện hành.
*--------------------------------------------------------------------*
*/

WITH certificate_document AS (
    SELECT
        sp_code,
        sp_license_certificate_document_code,
        issue_dt,
        revocation_dt,
        src_stm_code,
        sp_license_certificate_document_id,
        sp_license_certificate_tp_id,
        issue_sp_license_decision_document_id,
        revocation_sp_license_decision_document_id,
        certificate_nbr
    FROM {{ ref('atm_sp_license_certificate_document') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_CERTIFICATE_RECORDS'
),

certificate_type AS (
    SELECT
        sp_license_certificate_tp_code,
        certificate_tp_nm,
        sp_license_certificate_tp_id
    FROM {{ ref('atm_sp_license_certificate_type') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

decision_document AS (
    SELECT
        decision_nbr,
        sp_license_decision_document_id
    FROM {{ ref('atm_sp_license_decision_document') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_DECISIONS'
),

certificate_status_history AS (
    SELECT
        sp_license_certificate_document_id,
        new_certificate_status_code
    FROM (
        SELECT
            sp_license_certificate_document_id,
            new_certificate_status_code,
            ROW_NUMBER() OVER (
                PARTITION BY sp_license_certificate_document_id
                ORDER BY data_dt DESC,
                    CAST(sp_license_certificate_status_change_history_code AS BIGINT) DESC
            ) AS rn
        FROM {{ ref('atm_sp_license_certificate_status_change_history') }}
        WHERE src_stm_code = 'NHNCK_CERTIFICATE_RECORD_STATUS_HISTORIES'
    ) t
    WHERE rn = 1
),

certificate_status_lookup AS (
    SELECT
        cl_nm,
        cl_code
    FROM {{ source('source_atm', 'raw_classification_value') }}
    WHERE schema_code = 'CERTIFICATE_STATUS'
)

SELECT
    CAST(certificate_document.sp_code AS string)                              AS practitioner_code,
    CAST(certificate_document.sp_license_certificate_document_code AS string) AS license_certificate_document_code,
    CAST(certificate_document.certificate_nbr AS string)                      AS certificate_nbr,
    CAST(certificate_type.sp_license_certificate_tp_code AS string)           AS certificate_tp_code,
    CAST(certificate_type.certificate_tp_nm AS string)                        AS certificate_tp_nm,
    CAST(certificate_document.issue_dt AS date)                               AS issue_dt,
    CAST(certificate_document.revocation_dt AS date)                          AS revocation_dt,
    CAST(decision_document.decision_nbr AS string)                            AS issue_decision_nbr,
    CAST(decision_document_2.decision_nbr AS string)                          AS revocation_decision_nbr,
    CAST(certificate_status_history.new_certificate_status_code AS string)    AS certificate_status_code,
    CAST(certificate_status_lookup.cl_nm AS string)                           AS certificate_status_nm,
    CAST(certificate_document.src_stm_code AS string)                         AS src_stm_code
FROM certificate_document
-- LEFT JOIN sp_or_em_re
--     ON sp_or_em_re.sp_license_certificate_document_id = certificate_document.sp_license_certificate_document_id
LEFT JOIN certificate_type
    ON certificate_type.sp_license_certificate_tp_id = certificate_document.sp_license_certificate_tp_id
LEFT JOIN decision_document
    ON decision_document.sp_license_decision_document_id = certificate_document.issue_sp_license_decision_document_id
LEFT JOIN decision_document AS decision_document_2
    ON decision_document_2.sp_license_decision_document_id = certificate_document.revocation_sp_license_decision_document_id
LEFT JOIN certificate_status_history
    ON certificate_status_history.sp_license_certificate_document_id = certificate_document.sp_license_certificate_document_id
LEFT JOIN certificate_status_lookup
    ON certificate_status_lookup.cl_code = certificate_status_history.new_certificate_status_code

