/*
*--------------------------------------------------------------------*
* Program code: stg_iss_input_report_submission
* Program name: Staging ISS.INPUT_REPORT_SUBMISSION
* Created by: tuan.nguyenvanb
* Created date: 2026-09-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                          AS id
    , CAST(input_report_id AS string)             AS input_report_id
    , CAST(submit_source AS string)               AS submit_source
    , CAST(file_info_id AS string)                AS file_info_id
    , CAST(submit_status AS string)                AS submit_status
    , CAST(note AS string)                         AS note
    , CAST(description AS string)                 AS description
    , CAST(compare_result_file_info_id AS string)  AS compare_result_file_info_id
    , CAST(compare_status AS string)              AS compare_status
    , CAST(submitted_at AS timestamp)             AS submitted_at
    , CAST(created_by_id AS string)               AS created_by_id
    , CAST(created_by_name AS string)             AS created_by_name
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(updated_by_id AS string)               AS updated_by_id
    , CAST(updated_by_name AS string)             AS updated_by_name
    , CAST(updated_at AS timestamp)               AS updated_at
    , CAST(deleted AS int)                        AS deleted
    , CAST(resubmit_reason AS string)             AS resubmit_reason
FROM {{ source('source_iss', 'raw_input_report_submission') }}
