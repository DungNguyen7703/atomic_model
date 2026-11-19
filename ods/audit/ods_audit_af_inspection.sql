/*
*--------------------------------------------------------------------*
* Program code: ods_audit_af_inspection
* Program name: ODS AUDIT.AF_INSPECTION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		[MOI] ODS AUDIT.AF_INSPECTION - loc ODS chi lay ban ghi con hoat dong o nguon: delete_flg = 0 (theo ma tran loc AUDIT).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , af_profile_id
    , inspection_authority_cd
    , inspection_team
    , inspection_decision_no
    , inspection_start_date
    , inspection_end_date
    , audit_system_result_cd
    , overall_result_cd
    , overall_action_cd
    , overall_action_type_cd
    , overall_document_no
    , overall_document_date
    , overall_violation_content
    , overall_effective_from_date
    , overall_effective_to_date
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , audit_technical_result_cd
FROM {{ ref('stg_audit_af_inspection') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0
