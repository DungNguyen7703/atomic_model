/*
*--------------------------------------------------------------------*
* Program code: stg_audit_alert_template_audit_dtl
* Program name: Staging AUDIT.ALERT_TEMPLATE_AUDIT_DTL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(id_hdr AS int)               AS id_hdr
    , CAST(form_id AS int)              AS form_id
    , CAST(expected_form_id AS int)     AS expected_form_id
    , CAST(condition_type AS string)    AS condition_type
    , CAST(compare_type AS string)      AS compare_type
    , CAST(actual_field AS int)         AS actual_field
    , CAST(expected_field AS int)       AS expected_field
    , CAST(expected_value AS string)    AS expected_value
    , CAST(actual_time_offset AS int)   AS actual_time_offset
    , CAST(expected_time_offset AS int) AS expected_time_offset
    , CAST(created_date AS date)        AS created_date
    , CAST(created_by AS string)        AS created_by
    , CAST(updated_date AS date)        AS updated_date
    , CAST(updated_by AS string)        AS updated_by
FROM {{ source('source_audit', 'raw_alert_template_audit_dtl') }}