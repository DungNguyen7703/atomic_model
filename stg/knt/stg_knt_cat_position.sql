/*
*--------------------------------------------------------------------*
* Program code: stg_knt_cat_position
* Program name: Staging KNT.CAT_POSITION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                  AS id
    , CAST(position_code AS string)    AS position_code
    , CAST(position_name AS string)    AS position_name
    , CAST(original_data AS int)       AS original_data
    , CAST(created_at AS date)         AS created_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_at AS date)   AS last_modified_at
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(data_type AS int)           AS data_type
    , CAST(deleted AS int)             AS deleted
    , CAST(sync_enabled AS int)        AS sync_enabled
    , CAST(sync_id AS string)          AS sync_id
    , CAST(sync_id_sc_firm AS string)  AS sync_id_sc_firm
FROM {{ source('source_knt', 'raw_cat_position') }}