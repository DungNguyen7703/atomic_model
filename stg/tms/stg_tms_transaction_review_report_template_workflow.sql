/*
*--------------------------------------------------------------------*
* Program code: stg_tms_transaction_review_report_template_workflow
* Program name: Staging TMS.TRANSACTION_REVIEW_REPORT_TEMPLATE_WORKFLOW
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
    , CAST(template_id AS string)           AS template_id
    , CAST(workflow_type AS int)            AS workflow_type
    , CAST(essential AS int)                AS essential
    , CAST(template_type AS int)            AS template_type
    , CAST(transaction_review_id AS string) AS transaction_review_id
    , CAST(report_type AS int)              AS report_type
    , CAST(parameters AS string)            AS parameters
    , CAST(securities_id AS string)         AS securities_id
    , CAST(securities_code AS string)       AS securities_code
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(created_by_id AS string)         AS created_by_id
    , CAST(created_by_name AS string)       AS created_by_name
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(updated_by_id AS string)         AS updated_by_id
    , CAST(updated_by_name AS string)       AS updated_by_name
    , CAST(deleted AS int)                  AS deleted
    , CAST(workflow_id AS string)           AS workflow_id
FROM {{ source('source_tms', 'raw_transaction_review_report_template_workflow') }}