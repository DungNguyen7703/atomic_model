/*
*--------------------------------------------------------------------*
* Program code: stg_tms_abnormal_extracted_signal
* Program name: Staging TMS.ABNORMAL_EXTRACTED_SIGNAL
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
    , CAST(report_type AS string)     AS report_type
    , CAST(report_id AS string)       AS report_id
    , CAST(report_form_id AS string)  AS report_form_id
    , CAST(submitter_id AS string)    AS submitter_id
    , CAST(form_code AS string)       AS form_code
    , CAST(row_index AS int)          AS row_index
    , CAST(column_code AS string)     AS column_code
    , CAST(account_code AS string)    AS account_code
    , CAST(semantic_field AS string)  AS semantic_field
    , CAST(value_norm AS string)      AS value_norm
    , CAST(paired_account AS string)  AS paired_account
    , CAST(occurred_date AS date)     AS occurred_date
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_abnormal_extracted_signal') }}