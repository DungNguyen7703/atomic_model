/*
*--------------------------------------------------------------------*
* Program code: stg_tms_analysis_suspicious_account_code
* Program name: Staging TMS.ANALYSIS_SUSPICIOUS_ACCOUNT_CODE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(template_id AS string)        AS template_id
    , CAST(case_file_id AS string)       AS case_file_id
    , CAST(workflow_type AS int)         AS workflow_type
    , CAST(account_code AS string)       AS account_code
    , CAST(created_at AS timestamp)      AS created_at
    , CAST(updated_at AS timestamp)      AS updated_at
    , CAST(created_by_id AS string)      AS created_by_id
    , CAST(updated_by_id AS string)      AS updated_by_id
    , CAST(created_by_name AS string)    AS created_by_name
    , CAST(updated_by_name AS string)    AS updated_by_name
    , CAST(deleted AS int)               AS deleted
    , CAST(securities_code_id AS string) AS securities_code_id
    , CAST(securities_code AS string)    AS securities_code
    , CAST(workflow_id AS string)        AS workflow_id
FROM {{ source('source_tms', 'raw_analysis_suspicious_account_code') }}