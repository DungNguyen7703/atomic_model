/*
*--------------------------------------------------------------------*
* Program code: stg_iam_resources
* Program name: Staging IAM.RESOURCES
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
    , CAST(description AS string)     AS description
    , CAST(status AS int)             AS status
    , CAST(deleted AS int)            AS deleted
    , CAST(module_id AS string)       AS module_id
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(version AS int)            AS version
    , CAST(delete_reason AS string)   AS delete_reason
FROM {{ source('source_iam', 'raw_resources') }}