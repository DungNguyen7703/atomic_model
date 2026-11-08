/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_technical_audit
* Program name: Staging AUDIT.AF_TECHNICAL_AUDIT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                                  AS id
    , CAST(af_profile_id AS int)                       AS af_profile_id
    , CAST(af_inspection_id AS int)                    AS af_inspection_id
    , CAST(inspection_entity_files AS string)          AS inspection_entity_files
    , CAST(inspection_year AS string)                  AS inspection_year
    , CAST(signing_auditor_name AS string)             AS signing_auditor_name
    , CAST(legal_representative_name AS string)        AS legal_representative_name
    , CAST(inspection_result_cd AS string)             AS inspection_result_cd
    , CAST(audit_action_cd AS string)                  AS audit_action_cd
    , CAST(action_type_cd AS string)                   AS action_type_cd
    , CAST(document_no AS string)                      AS document_no
    , CAST(document_date AS date)                      AS document_date
    , CAST(violation_content AS string)                AS violation_content
    , CAST(effective_from_date AS date)                AS effective_from_date
    , CAST(effective_to_date AS date)                  AS effective_to_date
    , CAST(created_by AS string)                       AS created_by
    , CAST(created_date AS date)                       AS created_date
    , CAST(updated_by AS string)                       AS updated_by
    , CAST(updated_date AS date)                       AS updated_date
    , CAST(delete_flg AS int)                          AS delete_flg
    , CAST(reason AS string)                           AS reason
    , CAST(ld_inspection_result_cd AS string)          AS ld_inspection_result_cd
    , CAST(ld_audit_action_cd AS string)               AS ld_audit_action_cd
    , CAST(ld_reason AS string)                        AS ld_reason
    , CAST(ld_document_no AS string)                   AS ld_document_no
    , CAST(ld_document_date AS date)                   AS ld_document_date
    , CAST(ld_violation_content AS string)             AS ld_violation_content
    , CAST(ld_effective_from_date AS date)             AS ld_effective_from_date
    , CAST(ld_effective_to_date AS date)               AS ld_effective_to_date
    , CAST(inspection_unit AS string)                  AS inspection_unit
    , CAST(inspection_type AS string)                  AS inspection_type
    , CAST(inspection_other_unit AS string)            AS inspection_other_unit
    , CAST(consider_next_year_processing AS string)    AS consider_next_year_processing
    , CAST(other_processing AS string)                 AS other_processing
    , CAST(ld_consider_next_year_processing AS string) AS ld_consider_next_year_processing
    , CAST(ld_other_processing AS string)              AS ld_other_processing
FROM {{ source('source_audit', 'raw_af_technical_audit') }}