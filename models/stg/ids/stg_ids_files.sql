/*
*--------------------------------------------------------------------*
* Program code: stg_ids_files
* Program name: Staging IDS.FILES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))          AS id
    , CAST(file_name AS string)          AS file_name
    , CAST(original_file_name AS string) AS original_file_name
    , CAST(content_type AS string)       AS content_type
    , CAST(file_size AS decimal(19,0))   AS file_size
    , CAST(minio_key AS string)          AS minio_key
    , CAST(bucket_name AS string)        AS bucket_name
    , CAST(file_path AS string)          AS file_path
    , CAST(description AS string)        AS description
    , CAST(table_name AS string)         AS table_name
    , CAST(object_id AS decimal(19,0))   AS object_id
    , CAST(draft_token AS string)        AS draft_token
    , CAST(file_status AS string)        AS file_status
    , CAST(file_category AS string)      AS file_category
    , CAST(created_by AS string)         AS created_by
    , CAST(created_date AS timestamp)    AS created_date
    , CAST(updated_by AS string)         AS updated_by
    , CAST(updated_date AS timestamp)    AS updated_date
FROM {{ source('source_ids', 'raw_files') }}