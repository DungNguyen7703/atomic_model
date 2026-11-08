/*
*--------------------------------------------------------------------*
* Program code: stg_iam_user_role
* Program name: Staging IAM.USER_ROLE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(user_id AS string) AS user_id
    , CAST(role_id AS string) AS role_id
FROM {{ source('source_iam', 'raw_user_role') }}