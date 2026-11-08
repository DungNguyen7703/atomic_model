/*
*--------------------------------------------------------------------*
* Program code: stg_audit_lookup_values
* Program name: Staging AUDIT.LOOKUP_VALUES
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                 AS id
    , CAST(lookup_group AS string)    AS lookup_group
    , CAST(lookup_cd AS string)       AS lookup_cd
    , CAST(lookup_value_vn AS string) AS lookup_value_vn
    , CAST(lookup_value_en AS string) AS lookup_value_en
    , CAST(display_order AS int)      AS display_order
    , CAST(description AS string)     AS description
    , CAST(active_flg AS int)         AS active_flg
    , CAST(created_by AS string)      AS created_by
    , CAST(created_date AS date)      AS created_date
    , CAST(updated_by AS string)      AS updated_by
    , CAST(updated_date AS date)      AS updated_date
    , CAST(sync_flg AS int)           AS sync_flg
    , CAST(delete_flg AS int)         AS delete_flg
    , CAST(system_cd AS string)       AS system_cd
    , CAST(lookup_parent_id AS int)   AS lookup_parent_id
FROM {{ source('source_audit', 'raw_lookup_values') }}