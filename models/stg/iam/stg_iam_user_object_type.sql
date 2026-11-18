/*
*--------------------------------------------------------------------*
* Program code: stg_iam_user_object_type
* Program name: Staging IAM.USER_OBJECT_TYPE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(code AS string)            AS code
    , CAST(name AS string)            AS name
    , CAST(user_type AS int)          AS user_type
    , CAST(partner_code AS string)    AS partner_code
    , CAST(partner_name AS string)    AS partner_name
    , CAST(module_code AS string)     AS module_code
    , CAST(module_name AS string)     AS module_name
    , CAST(description AS string)     AS description
    , CAST(display_order AS int)      AS display_order
    , CAST(status AS int)             AS status
    , CAST(deleted AS int)            AS deleted
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(version AS int)            AS version
FROM {{ source('source_iam', 'raw_user_object_type') }}