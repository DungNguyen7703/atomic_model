/*
*--------------------------------------------------------------------*
* Program code: stg_iss_user_permission_group
* Program name: Staging ISS.USER_PERMISSION_GROUP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_ISS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(user_id AS string)                    AS user_id
    , CAST(report_permission_group_id AS string) AS report_permission_group_id
    , CAST(created_by_id AS string)              AS created_by_id
    , CAST(created_by_name AS string)            AS created_by_name
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(updated_by_id AS string)              AS updated_by_id
    , CAST(updated_by_name AS string)            AS updated_by_name
    , CAST(updated_at AS timestamp)              AS updated_at
    , CAST(deleted AS int)                       AS deleted
FROM {{ source('source_iss', 'raw_user_permission_group') }}