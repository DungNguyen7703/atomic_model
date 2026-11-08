/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_inspection
* Program name: Staging AUDIT.AF_INSPECTION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                           AS id
    , CAST(af_profile_id AS int)                AS af_profile_id
    , CAST(inspection_authority_cd AS string)   AS inspection_authority_cd
    , CAST(inspection_team AS string)           AS inspection_team
    , CAST(inspection_decision_no AS string)    AS inspection_decision_no
    , CAST(inspection_start_date AS date)       AS inspection_start_date
    , CAST(inspection_end_date AS date)         AS inspection_end_date
    , CAST(audit_system_result_cd AS string)    AS audit_system_result_cd
    , CAST(overall_result_cd AS string)         AS overall_result_cd
    , CAST(overall_action_cd AS string)         AS overall_action_cd
    , CAST(overall_action_type_cd AS string)    AS overall_action_type_cd
    , CAST(overall_document_no AS string)       AS overall_document_no
    , CAST(overall_document_date AS date)       AS overall_document_date
    , CAST(overall_violation_content AS string) AS overall_violation_content
    , CAST(overall_effective_from_date AS date) AS overall_effective_from_date
    , CAST(overall_effective_to_date AS date)   AS overall_effective_to_date
    , CAST(created_by AS string)                AS created_by
    , CAST(created_date AS date)                AS created_date
    , CAST(updated_by AS string)                AS updated_by
    , CAST(updated_date AS date)                AS updated_date
    , CAST(delete_flg AS int)                   AS delete_flg
    , CAST(audit_technical_result_cd AS string) AS audit_technical_result_cd
FROM {{ source('source_audit', 'raw_af_inspection') }}