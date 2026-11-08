/*
*--------------------------------------------------------------------*
* Program code: stg_ids_stock_controls
* Program name: Staging IDS.STOCK_CONTROLS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(restricted_share_qty AS int)    AS restricted_share_qty
    , CAST(restriction_start_date AS date) AS restriction_start_date
    , CAST(restriction_end_date AS date)   AS restriction_end_date
    , CAST(legal_entity_id AS int)         AS legal_entity_id
    , CAST(exp_status_flg AS int)          AS exp_status_flg
    , CAST(restriction_type_cd AS string)  AS restriction_type_cd
    , CAST(created_by AS string)           AS created_by
    , CAST(created_date AS date)           AS created_date
    , CAST(updated_by AS string)           AS updated_by
    , CAST(updated_date AS date)           AS updated_date
    , CAST(delete_flg AS int)              AS delete_flg
FROM {{ source('source_ids', 'raw_stock_controls') }}