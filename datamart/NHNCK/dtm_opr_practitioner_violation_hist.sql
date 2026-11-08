/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_violation_hist
* Program name: Dtm Opr Practitioner Violation Hist
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH conduct_violation AS (
    SELECT
        sp_code,
        sp_conduct_violation_code,
        violation_tp_code,
        violation_status_code,
        note,
        src_stm_code,
        sp_license_decision_document_id
    FROM {{ ref('atm_sp_conduct_violation') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_VIOLATIONS'
),

decision_document AS (
    SELECT
        decision_nbr,
        decision_signed_dt,
        sp_license_decision_document_id
    FROM {{ ref('atm_sp_license_decision_document') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_DECISIONS'
),

category_value AS (
    SELECT
        cl_nm,
        cl_code,
        schema_code
    FROM {{ source('source_atm', 'raw_classification_value') }}
)

SELECT
    CAST(conduct_violation.sp_code AS string)                   AS practitioner_code,
    CAST(conduct_violation.sp_conduct_violation_code AS string) AS conduct_violation_code,
    CAST(conduct_violation.violation_tp_code AS string)         AS violation_tp_code,
    CAST(violation_type_lookup.cl_nm AS string)                          AS violation_tp_nm,
    CAST(conduct_violation.note AS string)                      AS note,
    CAST(conduct_violation.violation_status_code AS string)     AS violation_status_code,
    CAST(violation_status_lookup.cl_nm AS string)                          AS violation_status_nm,
    CAST(decision_document.decision_nbr AS string)           AS decision_nbr,
    CAST(decision_document.decision_signed_dt AS date)       AS decision_signed_dt,
    CAST(conduct_violation.src_stm_code AS string)              AS src_stm_code
FROM conduct_violation
LEFT JOIN decision_document
    ON decision_document.sp_license_decision_document_id = conduct_violation.sp_license_decision_document_id
LEFT JOIN category_value violation_type_lookup
    ON violation_type_lookup.cl_code = conduct_violation.violation_tp_code
    AND violation_type_lookup.schema_code = 'VIOLATION_TYPE'
LEFT JOIN category_value violation_status_lookup
    ON violation_status_lookup.cl_code = conduct_violation.violation_status_code
    AND violation_status_lookup.schema_code = 'VIOLATION_STATUS'
