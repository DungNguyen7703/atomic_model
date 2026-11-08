/*
*--------------------------------------------------------------------*
* Program code: stg_tms_transaction_review
* Program name: Staging TMS.TRANSACTION_REVIEW
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                       AS id
    , CAST(job_code AS string)                 AS job_code
    , CAST(job_name AS string)                 AS job_name
    , CAST(analysis_start_date AS timestamp)   AS analysis_start_date
    , CAST(analysis_end_date AS timestamp)     AS analysis_end_date
    , CAST(processing_start_date AS timestamp) AS processing_start_date
    , CAST(processing_end_date AS timestamp)   AS processing_end_date
    , CAST(description AS string)              AS description
    , CAST(job_type AS int)                    AS job_type
    , CAST(status AS int)                      AS status
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(created_by_id AS string)            AS created_by_id
    , CAST(updated_by_id AS string)            AS updated_by_id
    , CAST(created_by_name AS string)          AS created_by_name
    , CAST(updated_by_name AS string)          AS updated_by_name
    , CAST(deleted AS int)                     AS deleted
    , CAST(assigned_to AS string)              AS assigned_to
    , CAST(rejection_reason AS string)         AS rejection_reason
    , CAST(information_source AS string)       AS information_source
FROM {{ source('source_tms', 'raw_transaction_review') }}