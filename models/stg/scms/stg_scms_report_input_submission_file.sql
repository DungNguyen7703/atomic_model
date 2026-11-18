/*
*--------------------------------------------------------------------*
* Program code: stg_scms_report_input_submission_file
* Program name: Staging SCMS.REPORT_INPUT_SUBMISSION_FILE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                         AS id
    , CAST(report_input_submission_id AS decimal(19,0)) AS report_input_submission_id
    , CAST(record_type AS string)                       AS record_type
    , CAST(path_url AS string)                          AS path_url
    , CAST(original_file_name AS string)                AS original_file_name
    , CAST(ref_type AS string)                          AS ref_type
FROM {{ source('source_scms', 'raw_report_input_submission_file') }}