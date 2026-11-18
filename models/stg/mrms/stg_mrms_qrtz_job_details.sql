/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_qrtz_job_details
* Program name: Staging MRMS.QRTZ_JOB_DETAILS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sched_name AS string)        AS sched_name
    , CAST(job_name AS string)          AS job_name
    , CAST(job_group AS string)         AS job_group
    , CAST(description AS string)       AS description
    , CAST(job_class_name AS string)    AS job_class_name
    , CAST(is_durable AS string)        AS is_durable
    , CAST(is_nonconcurrent AS string)  AS is_nonconcurrent
    , CAST(is_update_data AS string)    AS is_update_data
    , CAST(requests_recovery AS string) AS requests_recovery
    , CAST(job_data AS string)          AS job_data
FROM {{ source('source_mrms', 'raw_qrtz_job_details') }}