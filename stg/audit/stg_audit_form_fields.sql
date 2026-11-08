/*
*--------------------------------------------------------------------*
* Program code: stg_audit_form_fields
* Program name: Staging AUDIT.FORM_FIELDS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                    AS id
    , CAST(field_id AS int)              AS field_id
    , CAST(field_parent_id AS int)       AS field_parent_id
    , CAST(form_id AS int)               AS form_id
    , CAST(field_name_vi AS string)      AS field_name_vi
    , CAST(field_name_en AS string)      AS field_name_en
    , CAST(data_type AS string)          AS data_type
    , CAST(field_order AS decimal(30,0)) AS field_order
    , CAST(parent_id AS decimal(19,0))   AS parent_id
    , CAST(field_format AS string)       AS field_format
    , CAST(required_flg AS int)          AS required_flg
    , CAST(correction_flg AS int)        AS correction_flg
    , CAST(published_flg AS int)         AS published_flg
    , CAST(active_flg AS int)            AS active_flg
    , CAST(doc_ref AS string)            AS doc_ref
    , CAST(created_by AS string)         AS created_by
    , CAST(created_date AS date)         AS created_date
    , CAST(last_updated_by AS string)    AS last_updated_by
    , CAST(last_updated_date AS date)    AS last_updated_date
    , CAST(system_cd AS string)          AS system_cd
    , CAST(read_only_flg AS int)         AS read_only_flg
FROM {{ source('source_audit', 'raw_form_fields') }}