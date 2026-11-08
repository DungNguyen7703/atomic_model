/*
*--------------------------------------------------------------------*
* Program code: stg_tms_suspicious_account
* Program name: Staging TMS.SUSPICIOUS_ACCOUNT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(case_file_id AS string)    AS case_file_id
    , CAST(account_id AS string)      AS account_id
    , CAST(criteria_flags AS string)  AS criteria_flags
    , CAST(source AS int)             AS source
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
    , CAST(version AS int)            AS version
FROM {{ source('source_tms', 'raw_suspicious_account') }}