/*
*--------------------------------------------------------------------*
* Program code: stg_tms_abnormal_report_template
* Program name: Staging TMS.ABNORMAL_REPORT_TEMPLATE
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
    , CAST(template_code AS string)   AS template_code
    , CAST(template_name AS string)   AS template_name
    , CAST(report_group AS string)    AS report_group
    , CAST(submitter_types AS string) AS submitter_types
    , CAST(description AS string)     AS description
    , CAST(status AS int)             AS status
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
FROM {{ source('source_tms', 'raw_abnormal_report_template') }}