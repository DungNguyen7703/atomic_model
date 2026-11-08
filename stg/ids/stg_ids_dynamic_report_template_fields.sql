/*
*--------------------------------------------------------------------*
* Program code: stg_ids_dynamic_report_template_fields
* Program name: Staging IDS.DYNAMIC_REPORT_TEMPLATE_FIELDS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(38,0))          AS id
    , CAST(template_id AS decimal(38,0)) AS template_id
    , CAST(field_id AS decimal(38,0))    AS field_id
    , CAST(display_order AS int)         AS display_order
FROM {{ source('source_ids', 'raw_dynamic_report_template_fields') }}