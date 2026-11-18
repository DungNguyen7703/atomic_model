/*
*--------------------------------------------------------------------*
* Program code: stg_iss_file_info
* Program name: Staging ISS.FILE_INFO
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_ISS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(file_name AS string)        AS file_name
    , CAST(file_extension AS string)   AS file_extension
    , CAST(object_key AS string)       AS object_key
    , CAST(file_size AS decimal(19,0)) AS file_size
    , CAST(display_name AS string)     AS display_name
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_iss', 'raw_file_info') }}