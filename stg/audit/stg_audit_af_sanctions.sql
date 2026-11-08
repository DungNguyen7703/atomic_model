/*
*--------------------------------------------------------------------*
* Program code: stg_audit_af_sanctions
* Program name: Staging AUDIT.AF_SANCTIONS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(af_profile_id AS int)            AS af_profile_id
    , CAST(sanction_authority_cd AS string) AS sanction_authority_cd
    , CAST(decision_no AS string)           AS decision_no
    , CAST(decision_date AS date)           AS decision_date
    , CAST(attachment_file_url AS string)   AS attachment_file_url
    , CAST(created_by AS string)            AS created_by
    , CAST(created_date AS date)            AS created_date
    , CAST(updated_by AS string)            AS updated_by
    , CAST(updated_date AS date)            AS updated_date
    , CAST(delete_flg AS int)               AS delete_flg
    , CAST(sanction_content AS string)      AS sanction_content
FROM {{ source('source_audit', 'raw_af_sanctions') }}