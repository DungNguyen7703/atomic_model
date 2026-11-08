/*
*--------------------------------------------------------------------*
* Program code: ods_ids_stock_listing_history
* Program name: ODS IDS.STOCK_LISTING_HISTORY
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
    , company_profile_id
    , action_type_cd
    , sequence_no
    , exchange_cd
    , equity_ticker
    , decision_no
    , decision_date
    , first_trading_date
    , delisting_date
    , listed_share_qty
    , change_share_qty
    , total_share_qty_after_change
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_ids_stock_listing_history') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')