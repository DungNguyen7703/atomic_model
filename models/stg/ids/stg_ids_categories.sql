/*
*--------------------------------------------------------------------*
* Program code: stg_ids_categories
* Program name: Staging IDS.CATEGORIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		Them cot delete_flg (nguon IDS.CATEGORIES co cot DELETE_FLG NUMBER(1,0)) de ODS loc delete_flg = 0 theo ma tran loc IDS.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                 AS id
    , CAST(industry_cd AS string)   AS industry_cd
    , CAST(industry_name AS string) AS industry_name
    , CAST(description AS string)   AS description
    , CAST(parent_id AS int)        AS parent_id
    , CAST(active_flg AS int)       AS active_flg
    , CAST(created_by AS string)    AS created_by
    , CAST(created_date AS date)    AS created_date
    , CAST(updated_by AS string)    AS updated_by
    , CAST(updated_date AS date)    AS updated_date
    , CAST(status_flg AS int)       AS status_flg
    , CAST(id_sync AS string)       AS id_sync
    , CAST(type AS string)          AS type
    , CAST(delete_flg AS int)       AS delete_flg
FROM {{ source('source_ids', 'raw_categories') }}