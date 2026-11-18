/*
*--------------------------------------------------------------------*
* Program code: stg_iam_permission_dependency
* Program name: Staging IAM.PERMISSION_DEPENDENCY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                       AS id
    , CAST(permission_id AS string)            AS permission_id
    , CAST(depends_on_permission_id AS string) AS depends_on_permission_id
    , CAST(dependency_type AS string)          AS dependency_type
    , CAST(description AS string)              AS description
    , CAST(created_by_id AS string)            AS created_by_id
    , CAST(updated_by_id AS string)            AS updated_by_id
    , CAST(created_by_name AS string)          AS created_by_name
    , CAST(updated_by_name AS string)          AS updated_by_name
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(version AS int)                     AS version
FROM {{ source('source_iam', 'raw_permission_dependency') }}