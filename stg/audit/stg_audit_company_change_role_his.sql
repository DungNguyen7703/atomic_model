/*
*--------------------------------------------------------------------*
* Program code: stg_audit_company_change_role_his
* Program name: Staging AUDIT.COMPANY_CHANGE_ROLE_HIS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)               AS id
    , CAST(username AS string)      AS username
    , CAST(af_profile_id AS int)    AS af_profile_id
    , CAST(mngt_start_date AS date) AS mngt_start_date
    , CAST(mngt_end_date AS date)   AS mngt_end_date
    , CAST(change_reason AS string) AS change_reason
    , CAST(changed_date AS date)    AS changed_date
    , CAST(login_id AS int)         AS login_id
FROM {{ source('source_audit', 'raw_company_change_role_his') }}