/*
*--------------------------------------------------------------------*
* Program code: ods_audit_af_legal_representative
* Program name: ODS AUDIT.AF_LEGAL_REPRESENTATIVE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		[MOI] ODS AUDIT.AF_LEGAL_REPRESENTATIVE - loc ODS chi lay ban ghi con hoat dong o nguon: delete_flg = 0 (theo ma tran loc AUDIT).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , af_profile_id
    , full_name
    , identity_no
    , phone_no
    , position_title_cd
    , appointment_start_date
    , appointment_end_date
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_audit_af_legal_representative') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0
