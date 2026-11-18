/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_report_input_source
* Program name: Staging SCMS.FORM_REPORT_INPUT_SOURCE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                       AS id
    , CAST(canonical_form_report_id AS decimal(19,0)) AS canonical_form_report_id
    , CAST(source_form_report_id AS decimal(19,0))    AS source_form_report_id
    , CAST(period_scope AS string)                    AS period_scope
    , CAST(priority AS int)                           AS priority
    , CAST(active AS int)                             AS active
    , CAST(note AS string)                            AS note
    , CAST(created_at AS timestamp)                   AS created_at
    , CAST(last_modified_at AS timestamp)             AS last_modified_at
FROM {{ source('source_scms', 'raw_form_report_input_source') }}