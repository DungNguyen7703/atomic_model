/*
*--------------------------------------------------------------------*
* Program code: ods_audit_af_sanctions
* Program name: ODS AUDIT.AF_SANCTIONS
* Created by: ngoc.pham
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		ngoc.pham		[MOI] Bo sung ODS theo brd_AUDIT.yaml (in_scope, data_change_mode Update -> Snapshot); cot theo ODS DDL
* 2026-11-12		tuan.nguyenvanb	Them loc ban ghi dang hoat dong: delete_flg = 0 (DELETE_FLG: 1-Da xoa, 0-Dang hoat dong).
* 2026-11-13		ngoc.pham		Stg doi sang Append: loc theo data_dt thay cho ds_snpst_dt; them cot data_dt cuoi SELECT; schema.yml: strategy=append, partition_by=['data_dt'].
*--------------------------------------------------------------------*
*/

SELECT
    id
    , af_profile_id
    , sanction_authority_cd
    , decision_no
    , decision_date
    , attachment_file_url
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , sanction_content
    , data_dt
FROM {{ ref('stg_audit_af_sanctions') }}
WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND delete_flg = 0
