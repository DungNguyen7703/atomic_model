/*
*--------------------------------------------------------------------*
* Program code: stg_iam_group_role
* Program name: Staging IAM.GROUP_ROLE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(group_id AS string) AS group_id
    , CAST(role_id AS string)  AS role_id
FROM {{ source('source_iam', 'raw_group_role') }}