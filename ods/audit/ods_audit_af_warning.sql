/*
*--------------------------------------------------------------------*
* Program code: ods_audit_af_warning
* Program name: ODS AUDIT.AF_WARNING
* Created by: tuan.nguyenvanb
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		[MOI] ODS AUDIT.AF_WARNING - loc ODS chi lay ban ghi con hoat dong o nguon: delete_flg = 0 (theo ma tran loc AUDIT).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , af_profile_id
    , af_auditor_profile_id
    , target_type_cd
    , source_type_cd
    , warning_doc_no
    , warning_issue_date
    , warning_start_date
    , warning_end_date
    , warning_content
    , warning_type_cd
    , af_inspection_id
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_audit_af_warning') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0
