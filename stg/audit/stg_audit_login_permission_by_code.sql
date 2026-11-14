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
* 2026-11-07		tuan.nguyenvanb		Dong bo theo AUDIT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu int sang bigint (4 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                 AS id
    , CAST(login_id AS bigint)           AS login_id
    , CAST(login_name AS string)      AS login_name
    , CAST(company_profile_id AS bigint) AS company_profile_id
    , CAST(system_cd AS string)       AS system_cd
    , CAST(created_by AS string)      AS created_by
    , CAST(created_date AS timestamp)    AS created_date
    , CAST(updated_by AS string)      AS updated_by
    , CAST(updated_date AS timestamp)    AS updated_date
    , CAST(af_profile_id AS bigint)      AS af_profile_id
FROM {{ source('source_audit', 'raw_login_permission_by_code') }}