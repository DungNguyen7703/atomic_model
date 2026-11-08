/*
*--------------------------------------------------------------------*
* Program code: stg_tms_abnormal_column_semantic
* Program name: Staging TMS.ABNORMAL_COLUMN_SEMANTIC
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
    , CAST(form_code AS string)       AS form_code
    , CAST(column_code AS string)     AS column_code
    , CAST(semantic_field AS string)  AS semantic_field
    , CAST(expected_label AS string)  AS expected_label
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_abnormal_column_semantic') }}