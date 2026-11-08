/*
*--------------------------------------------------------------------*
* Program code: stg_tms_abnormal_report_data
* Program name: Staging TMS.ABNORMAL_REPORT_DATA
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                AS id
    , CAST(report_form_id AS string)    AS report_form_id
    , CAST(row_index AS int)            AS row_index
    , CAST(row_data AS string)          AS row_data
    , CAST(validation_status AS int)    AS validation_status
    , CAST(validation_errors AS string) AS validation_errors
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by_id AS string)     AS created_by_id
    , CAST(updated_by_id AS string)     AS updated_by_id
    , CAST(created_by_name AS string)   AS created_by_name
    , CAST(updated_by_name AS string)   AS updated_by_name
    , CAST(deleted AS int)              AS deleted
FROM {{ source('source_tms', 'raw_abnormal_report_data') }}