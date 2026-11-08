/*
*--------------------------------------------------------------------*
* Program code: stg_tms_case_attach_file
* Program name: Staging TMS.CASE_ATTACH_FILE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(case_file_id AS string)     AS case_file_id
    , CAST(file_name AS string)        AS file_name
    , CAST(file_path AS string)        AS file_path
    , CAST(file_size AS decimal(19,0)) AS file_size
    , CAST(file_type AS string)        AS file_type
    , CAST(file_group AS int)          AS file_group
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
    , CAST(report_name AS string)      AS report_name
FROM {{ source('source_tms', 'raw_case_attach_file') }}