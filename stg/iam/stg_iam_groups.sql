/*
*--------------------------------------------------------------------*
* Program code: stg_iam_groups
* Program name: Staging IAM.GROUPS
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
    , CAST(deleted AS int)            AS deleted
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(version AS int)            AS version
    , CAST(delete_reason AS string)   AS delete_reason
    , CAST(description AS string)     AS description
FROM {{ source('source_iam', 'raw_groups') }}