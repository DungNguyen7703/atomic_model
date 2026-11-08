/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_indicator_reference_value
* Program name: Staging SCMS.FORM_INDICATOR_REFERENCE_VALUE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))           AS id
    , CAST(code AS string)                AS code
    , CAST(item_name AS string)           AS item_name
    , CAST(record_status AS int)          AS record_status
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
FROM {{ source('source_scms', 'raw_form_indicator_reference_value') }}