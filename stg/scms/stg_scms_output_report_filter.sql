/*
*--------------------------------------------------------------------*
* Program code: stg_scms_output_report_filter
* Program name: Staging SCMS.OUTPUT_REPORT_FILTER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                AS id
    , CAST(form_report_id AS decimal(19,0))    AS form_report_id
    , CAST(filter_catalog_id AS decimal(19,0)) AS filter_catalog_id
    , CAST(allow_select AS int)                AS allow_select
    , CAST(default_value AS string)            AS default_value
    , CAST(sort_order AS bigint)               AS sort_order
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(created_by AS decimal(19,0))        AS created_by
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(updated_by AS decimal(19,0))        AS updated_by
    , CAST(is_visible AS int)                  AS is_visible
FROM {{ source('source_scms', 'raw_output_report_filter') }}