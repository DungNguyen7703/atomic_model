/*
*--------------------------------------------------------------------*
* Program code: stg_iam_role_permission
* Program name: Staging IAM.ROLE_PERMISSION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(role_id AS string)       AS role_id
    , CAST(permission_id AS string) AS permission_id
FROM {{ source('source_iam', 'raw_role_permission') }}