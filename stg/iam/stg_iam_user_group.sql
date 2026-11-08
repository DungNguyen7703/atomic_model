/*
*--------------------------------------------------------------------*
* Program code: stg_iam_user_group
* Program name: Staging IAM.USER_GROUP
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
    , CAST(user_id AS string)  AS user_id
FROM {{ source('source_iam', 'raw_user_group') }}