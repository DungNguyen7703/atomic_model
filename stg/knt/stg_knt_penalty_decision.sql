/*
*--------------------------------------------------------------------*
* Program code: stg_knt_penalty_decision
* Program name: Staging KNT.PENALTY_DECISION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(inspection_dossier_id AS string)   AS inspection_dossier_id
    , CAST(complaint_dossier_id AS string)    AS complaint_dossier_id
    , CAST(penalty_decision_number AS string) AS penalty_decision_number
    , CAST(violation_record_number AS string) AS violation_record_number
    , CAST(violation_record_date AS date)     AS violation_record_date
    , CAST(main_penalty_type AS int)          AS main_penalty_type
    , CAST(supplementary_penalty AS string)   AS supplementary_penalty
    , CAST(aggravating_mitigating AS string)  AS aggravating_mitigating
    , CAST(total_fine_amount AS int)          AS total_fine_amount
    , CAST(note AS string)                    AS note
    , CAST(status AS int)                     AS status
    , CAST(created_by AS string)              AS created_by
    , CAST(created_at AS date)                AS created_at
    , CAST(aml_violation AS int)              AS aml_violation
    , CAST(paid_fine_amount AS int)           AS paid_fine_amount
    , CAST(complaint_id AS string)            AS complaint_id
    , CAST(subject_type AS int)               AS subject_type
    , CAST(subject_id AS string)              AS subject_id
    , CAST(subject_name AS string)            AS subject_name
    , CAST(inspected_subject_id AS string)    AS inspected_subject_id
    , CAST(classification AS int)             AS classification
    , CAST(full_search AS string)             AS full_search
    , CAST(end_date AS date)                  AS end_date
    , CAST(violation_amount AS int)           AS violation_amount
    , CAST(decision_revision_count AS int)    AS decision_revision_count
    , CAST(enforcement_from_date AS date)     AS enforcement_from_date
    , CAST(enforcement_to_date AS date)       AS enforcement_to_date
    , CAST(decision_signed_date AS date)      AS decision_signed_date
    , CAST(content AS string)                 AS content
    , CAST(revoke_license_flag AS int)        AS revoke_license_flag
    , CAST(suspend_operation_flag AS int)     AS suspend_operation_flag
    , CAST(suspension_duration AS string)     AS suspension_duration
    , CAST(decision_name AS string)           AS decision_name
FROM {{ source('source_knt', 'raw_penalty_decision') }}