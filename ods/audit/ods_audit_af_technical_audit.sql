/*
*--------------------------------------------------------------------*
* Program code: ods_audit_af_technical_audit
* Program name: ODS AUDIT.AF_TECHNICAL_AUDIT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		[MOI] ODS AUDIT.AF_TECHNICAL_AUDIT - loc ODS chi lay ban ghi con hoat dong o nguon: delete_flg = 0 (theo ma tran loc AUDIT).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , af_profile_id
    , af_inspection_id
    , inspection_entity_files
    , inspection_year
    , signing_auditor_name
    , legal_representative_name
    , inspection_result_cd
    , audit_action_cd
    , action_type_cd
    , document_no
    , document_date
    , violation_content
    , effective_from_date
    , effective_to_date
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , reason
    , ld_inspection_result_cd
    , ld_audit_action_cd
    , ld_reason
    , ld_document_no
    , ld_document_date
    , ld_violation_content
    , ld_effective_from_date
    , ld_effective_to_date
    , inspection_unit
    , inspection_type
    , inspection_other_unit
    , consider_next_year_processing
    , other_processing
    , ld_consider_next_year_processing
    , ld_other_processing
FROM {{ ref('stg_audit_af_technical_audit') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0
