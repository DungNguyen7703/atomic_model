/*
*--------------------------------------------------------------------*
* Program code: stg_audit_data_values
* Program name: Staging AUDIT.DATA_VALUES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))           AS id
    , CAST(field_name_vi AS string)       AS field_name_vi
    , CAST(field_name_en AS string)       AS field_name_en
    , CAST(text_value AS string)          AS text_value
    , CAST(date_value AS date)            AS date_value
    , CAST(number_value AS decimal(38,2)) AS number_value
    , CAST(company_data_id AS int)        AS company_data_id
    , CAST(parent_id AS decimal(19,0))    AS parent_id
    , CAST(form_id AS int)                AS form_id
    , CAST(field_id AS int)               AS field_id
    , CAST(form_field_id AS int)          AS form_field_id
    , CAST(field_parent_id AS int)        AS field_parent_id
    , CAST(data_type AS string)           AS data_type
    , CAST(required_flg AS int)           AS required_flg
    , CAST(created_by AS string)          AS created_by
    , CAST(created_date AS date)          AS created_date
    , CAST(updated_by AS string)          AS updated_by
    , CAST(updated_date AS date)          AS updated_date
FROM {{ source('source_audit', 'raw_data_values') }}