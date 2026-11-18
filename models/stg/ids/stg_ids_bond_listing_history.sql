/*
*--------------------------------------------------------------------*
* Program code: stg_ids_bond_listing_history
* Program name: Staging IDS.BOND_LISTING_HISTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-30		tuan.nguyenvanb		Viet lai danh sach cot theo DDL nguon IDS.BOND_LISTING_HISTORY. Ban cu lay nham cot cua bang BOND_LISTING (company_profile_id, bond_ticker, is_deleted...). Cot xoa mem la delete_flg.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                                 AS id
    , CAST(bond_listing_id AS int)                  AS bond_listing_id
    , CAST(remaining_tenor AS int)                  AS remaining_tenor
    , CAST(issuance_qty AS decimal(19,0))           AS issuance_qty
    , CAST(repurchase_conversion_swap_qty AS decimal(19,0)) AS repurchase_conversion_swap_qty
    , CAST(registered_trading_qty AS decimal(19,0)) AS registered_trading_qty
    , CAST(outstanding_qty AS decimal(19,0))        AS outstanding_qty
    , CAST(first_trading_date AS date)              AS first_trading_date
    , CAST(last_trading_date AS date)               AS last_trading_date
    , CAST(trading_status AS string)                AS trading_status
    , CAST(created_by AS string)                    AS created_by
    , CAST(created_date AS date)                    AS created_date
    , CAST(updated_by AS string)                    AS updated_by
    , CAST(updated_date AS date)                    AS updated_date
    , CAST(delete_flg AS int)                       AS delete_flg
FROM {{ source('source_ids', 'raw_bond_listing_history') }}
