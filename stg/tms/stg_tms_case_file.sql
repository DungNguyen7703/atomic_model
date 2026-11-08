/*
*--------------------------------------------------------------------*
* Program code: stg_tms_case_file
* Program name: Staging TMS.CASE_FILE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                          AS id
    , CAST(case_file_code AS string)            AS case_file_code
    , CAST(case_file_type AS int)               AS case_file_type
    , CAST(securities_code_id AS string)        AS securities_code_id
    , CAST(securities_code AS string)           AS securities_code
    , CAST(information_source AS string)        AS information_source
    , CAST(completion_date AS date)             AS completion_date
    , CAST(start_date AS date)                  AS start_date
    , CAST(end_date AS date)                    AS end_date
    , CAST(assigned_to AS string)               AS assigned_to
    , CAST(notes AS string)                     AS notes
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(updated_at AS timestamp)             AS updated_at
    , CAST(created_by_id AS string)             AS created_by_id
    , CAST(updated_by_id AS string)             AS updated_by_id
    , CAST(created_by_name AS string)           AS created_by_name
    , CAST(updated_by_name AS string)           AS updated_by_name
    , CAST(deleted AS int)                      AS deleted
    , CAST(version AS bigint)                   AS version
    , CAST(information_source_detail AS string) AS information_source_detail
    , CAST(processing_start_time AS timestamp)  AS processing_start_time
    , CAST(processing_end_time AS timestamp)    AS processing_end_time
    , CAST(duration_time AS timestamp)          AS duration_time
    , CAST(case_file_status_id AS string)       AS case_file_status_id
    , CAST(abnormal_report_master_id AS string) AS abnormal_report_master_id
FROM {{ source('source_tms', 'raw_case_file') }}