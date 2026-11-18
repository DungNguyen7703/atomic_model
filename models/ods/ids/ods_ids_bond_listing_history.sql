/*
*--------------------------------------------------------------------*
* Program code: ods_ids_bond_listing_history
* Program name: ODS IDS.BOND_LISTING_HISTORY
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
    , bond_ticker
    , bond_type_cd
    , decision_no
    , decision_date
    , issuance_qty
    , par_value
    , coupon_rate
    , issuance_start_date
    , issuance_end_date
    , maturity_date
    , issuance_category_cd
    , created_by
    , created_date
    , updated_by
    , updated_date
    , is_deleted
    , is_sync
FROM {{ ref('stg_ids_bond_listing_history') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')