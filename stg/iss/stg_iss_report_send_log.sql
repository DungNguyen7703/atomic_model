/*
*--------------------------------------------------------------------*
* Program code: stg_iss_report_send_log
* Program name: Staging ISS.REPORT_SEND_LOG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_ISS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(input_report_submission_id AS string) AS input_report_submission_id
    , CAST(output_report_id AS string)           AS output_report_id
    , CAST(report_type AS string)                AS report_type
    , CAST(file_info_id AS string)               AS file_info_id
    , CAST(report_code AS string)                AS report_code
    , CAST(report_name AS string)                AS report_name
    , CAST(period_type AS string)                AS period_type
    , CAST(period_value AS string)               AS period_value
    , CAST(send_at AS timestamp)                 AS send_at
    , CAST(status AS string)                     AS status
    , CAST(note AS string)                       AS note
    , CAST(data_file_info_id AS string)          AS data_file_info_id
    , CAST(created_by_id AS string)              AS created_by_id
    , CAST(created_by_name AS string)            AS created_by_name
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(updated_by_id AS string)              AS updated_by_id
    , CAST(updated_by_name AS string)            AS updated_by_name
    , CAST(updated_at AS timestamp)              AS updated_at
    , CAST(deleted AS int)                       AS deleted
    , CAST(submit_status AS string)              AS submit_status
    , CAST(resubmit_reason AS string)            AS resubmit_reason
FROM {{ source('source_iss', 'raw_report_send_log') }}