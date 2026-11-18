/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_treasury_stocks
* Program name: Staging IDS.COMPANY_TREASURY_STOCKS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                    AS id
    , CAST(company_profile_id AS int)  AS company_profile_id
    , CAST(transaction_year AS string) AS transaction_year
    , CAST(treasury_buy_qty AS int)    AS treasury_buy_qty
    , CAST(treasury_buy_rc AS int)     AS treasury_buy_rc
    , CAST(treasury_sell_qty AS int)   AS treasury_sell_qty
    , CAST(treasury_sell_rc AS int)    AS treasury_sell_rc
    , CAST(created_by AS string)       AS created_by
    , CAST(created_date AS date)       AS created_date
    , CAST(updated_by AS string)       AS updated_by
    , CAST(updated_date AS date)       AS updated_date
    , CAST(delete_flg AS int)          AS delete_flg
    , CAST(is_sync AS int)             AS is_sync
FROM {{ source('source_ids', 'raw_company_treasury_stocks') }}