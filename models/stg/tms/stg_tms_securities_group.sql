/*
*--------------------------------------------------------------------*
* Program code: stg_tms_securities_group
* Program name: Staging TMS.SECURITIES_GROUP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(group_code AS string)      AS group_code
    , CAST(group_name AS string)      AS group_name
    , CAST(group_type AS int)         AS group_type
    , CAST(description AS string)     AS description
    , CAST(status AS int)             AS status
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_securities_group') }}