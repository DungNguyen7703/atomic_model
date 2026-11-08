/*
*--------------------------------------------------------------------*
* Program code: stg_iam_user_sub_types
* Program name: Staging IAM.USER_SUB_TYPES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(code AS string)             AS code
    , CAST(name AS string)             AS name
    , CAST(parent_sub_types AS string) AS parent_sub_types
    , CAST(deleted AS int)             AS deleted
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(version AS int)             AS version
FROM {{ source('source_iam', 'raw_user_sub_types') }}