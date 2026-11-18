/*
*--------------------------------------------------------------------*
* Program code: ods_ids_stock_controls
* Program name: ODS IDS.STOCK_CONTROLS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , restricted_share_qty
    , restriction_start_date
    , restriction_end_date
    , legal_entity_id
    , exp_status_flg
    , restriction_type_cd
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_ids_stock_controls') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')