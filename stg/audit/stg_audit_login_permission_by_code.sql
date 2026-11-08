/*
*--------------------------------------------------------------------*
* Program code: stg_audit_login_permission_by_code
* Program name: Staging AUDIT.LOGIN_PERMISSION_BY_CODE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                 AS id
    , CAST(login_id AS int)           AS login_id
    , CAST(login_name AS string)      AS login_name
    , CAST(company_profile_id AS int) AS company_profile_id
    , CAST(system_cd AS string)       AS system_cd
    , CAST(created_by AS string)      AS created_by
    , CAST(created_date AS date)      AS created_date
    , CAST(updated_by AS string)      AS updated_by
    , CAST(updated_date AS date)      AS updated_date
    , CAST(af_profile_id AS int)      AS af_profile_id
FROM {{ source('source_audit', 'raw_login_permission_by_code') }}