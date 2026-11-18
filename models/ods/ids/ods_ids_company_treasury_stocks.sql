/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_treasury_stocks
* Program name: ODS IDS.COMPANY_TREASURY_STOCKS
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
    , transaction_year
    , treasury_buy_qty
    , treasury_buy_rc
    , treasury_sell_qty
    , treasury_sell_rc
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , is_sync
FROM {{ ref('stg_ids_company_treasury_stocks') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')