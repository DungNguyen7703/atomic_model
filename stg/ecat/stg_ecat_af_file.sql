/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_af_file
* Program name: Staging ECAT.AF_FILE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(ref_type AS string)              AS ref_type
    , CAST(ref_id AS string)                AS ref_id
    , CAST(file_name AS string)             AS file_name
    , CAST(original_file_name AS string)    AS original_file_name
    , CAST(content_type AS string)          AS content_type
    , CAST(file_size AS decimal(19,0))      AS file_size
    , CAST(minio_key AS string)             AS minio_key
    , CAST(bucket_name AS string)           AS bucket_name
    , CAST(file_path AS string)             AS file_path
    , CAST(description AS string)           AS description
    , CAST(draft_token AS string)           AS draft_token
    , CAST(file_status AS string)           AS file_status
    , CAST(file_category AS string)         AS file_category
    , CAST(id_sync AS decimal(22,0))        AS id_sync
    , CAST(object_id_sync AS decimal(22,0)) AS object_id_sync
    , CAST(deleted AS int)                  AS deleted
    , CAST(created_by AS string)            AS created_by
    , CAST(created_date AS timestamp)       AS created_date
    , CAST(updated_by AS string)            AS updated_by
    , CAST(updated_date AS timestamp)       AS updated_date
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(updated_at AS timestamp)         AS updated_at
FROM {{ source('source_ecat', 'raw_af_file') }}