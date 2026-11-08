/*
*--------------------------------------------------------------------*
* Program code: stg_tms_transaction_review_report_parameter_value
* Program name: Staging TMS.TRANSACTION_REVIEW_REPORT_PARAMETER_VALUE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(transaction_review_id AS string) AS transaction_review_id
    , CAST(report_parameter_id AS string)   AS report_parameter_id
    , CAST(attribute_catalog_id AS string)  AS attribute_catalog_id
    , CAST(workflow_type AS int)            AS workflow_type
    , CAST(workflow_id AS string)           AS workflow_id
    , CAST(value_number AS decimal(19,6))   AS value_number
    , CAST(value_string AS string)          AS value_string
    , CAST(value_date AS date)              AS value_date
    , CAST(value_boolean AS int)            AS value_boolean
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(created_by_id AS string)         AS created_by_id
    , CAST(updated_by_id AS string)         AS updated_by_id
    , CAST(created_by_name AS string)       AS created_by_name
    , CAST(updated_by_name AS string)       AS updated_by_name
    , CAST(deleted AS int)                  AS deleted
FROM {{ source('source_tms', 'raw_transaction_review_report_parameter_value') }}