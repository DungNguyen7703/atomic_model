/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_gms_ids_lookup_values
* Program name: Staging ECAT.GMS_IDS_LOOKUP_VALUES
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(id_sync AS string)          AS id_sync
    , CAST(lookup_group AS string)     AS lookup_group
    , CAST(lookup_cd AS string)        AS lookup_cd
    , CAST(lookup_value_vn AS string)  AS lookup_value_vn
    , CAST(lookup_value_en AS string)  AS lookup_value_en
    , CAST(display_order AS int)       AS display_order
    , CAST(description AS string)      AS description
    , CAST(active_flg AS int)          AS active_flg
    , CAST(created_by AS string)       AS created_by
    , CAST(created_date AS timestamp)  AS created_date
    , CAST(updated_by AS string)       AS updated_by
    , CAST(updated_date AS timestamp)  AS updated_date
    , CAST(sync_flg AS int)            AS sync_flg
    , CAST(delete_flg AS int)          AS delete_flg
    , CAST(system_cd AS string)        AS system_cd
    , CAST(lookup_parent_id AS bigint) AS lookup_parent_id
FROM {{ source('source_ecat', 'raw_gms_ids_lookup_values') }}