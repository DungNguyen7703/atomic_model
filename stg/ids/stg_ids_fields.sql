/*
*--------------------------------------------------------------------*
* Program code: stg_ids_fields
* Program name: Staging IDS.FIELDS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(field_name_vi AS string)     AS field_name_vi
    , CAST(field_name_en AS string)     AS field_name_en
    , CAST(data_type AS string)         AS data_type
    , CAST(repeatable_flg AS int)       AS repeatable_flg
    , CAST(form_type AS string)         AS form_type
    , CAST(parent_id AS int)            AS parent_id
    , CAST(lookup_group AS string)      AS lookup_group
    , CAST(control_unit_cd AS string)   AS control_unit_cd
    , CAST(operating_unit_cd AS string) AS operating_unit_cd
    , CAST(created_by AS string)        AS created_by
    , CAST(created_date AS date)        AS created_date
    , CAST(updated_by AS string)        AS updated_by
    , CAST(updated_date AS date)        AS updated_date
    , CAST(delete_flg AS int)           AS delete_flg
    , CAST(active_flg AS int)           AS active_flg
FROM {{ source('source_ids', 'raw_fields') }}