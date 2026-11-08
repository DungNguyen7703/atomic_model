/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_qrtz_job_details
* Program name: Staging ECAT.QRTZ_JOB_DETAILS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)          AS sched_name
    , CAST(job_name AS string)          AS job_name
    , CAST(job_group AS string)         AS job_group
    , CAST(description AS string)       AS description
    , CAST(job_class_name AS string)    AS job_class_name
    , CAST(is_durable AS string)        AS is_durable
    , CAST(is_nonconcurrent AS string)  AS is_nonconcurrent
    , CAST(is_update_data AS string)    AS is_update_data
    , CAST(requests_recovery AS string) AS requests_recovery
    , CAST(job_data AS string)          AS job_data
FROM {{ source('source_ecat', 'raw_qrtz_job_details') }}