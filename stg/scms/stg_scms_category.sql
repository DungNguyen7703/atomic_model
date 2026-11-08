/*
*--------------------------------------------------------------------*
* Program code: stg_scms_category
* Program name: Staging SCMS.CATEGORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                       AS id
    , CAST(code AS string)          AS code
    , CAST(created_at AS timestamp) AS created_at
    , CAST(created_by AS string)    AS created_by
    , CAST(description AS string)   AS description
    , CAST(item_name AS string)     AS item_name
    , CAST(record_status AS string) AS record_status
    , CAST(updated_at AS timestamp) AS updated_at
    , CAST(updated_by AS string)    AS updated_by
FROM {{ source('source_scms', 'raw_category') }}