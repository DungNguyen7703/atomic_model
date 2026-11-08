/*
*--------------------------------------------------------------------*
* Program code: stg_tms_document_template_field
* Program name: Staging TMS.DOCUMENT_TEMPLATE_FIELD
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
    , CAST(template_id AS string)     AS template_id
    , CAST(display_name AS string)    AS display_name
    , CAST(field_code AS string)      AS field_code
    , CAST(input_format AS int)       AS input_format
    , CAST(display_order AS int)      AS display_order
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(updated_at AS timestamp)   AS updated_at
    , CAST(created_by_id AS string)   AS created_by_id
    , CAST(updated_by_id AS string)   AS updated_by_id
    , CAST(created_by_name AS string) AS created_by_name
    , CAST(updated_by_name AS string) AS updated_by_name
    , CAST(deleted AS int)            AS deleted
    , CAST(example_data AS string)    AS example_data
FROM {{ source('source_tms', 'raw_document_template_field') }}