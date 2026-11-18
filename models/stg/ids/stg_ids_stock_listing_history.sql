/*
*--------------------------------------------------------------------*
* Program code: stg_ids_stock_listing_history
* Program name: Staging IDS.STOCK_LISTING_HISTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                             AS id
    , CAST(company_profile_id AS int)           AS company_profile_id
    , CAST(action_type_cd AS string)            AS action_type_cd
    , CAST(sequence_no AS int)                  AS sequence_no
    , CAST(exchange_cd AS string)               AS exchange_cd
    , CAST(equity_ticker AS string)             AS equity_ticker
    , CAST(decision_no AS string)               AS decision_no
    , CAST(decision_date AS date)               AS decision_date
    , CAST(trading_date AS date)          AS first_trading_date
    , CAST(delisting_date AS date)              AS delisting_date
    , CAST(listed_share_qty AS int)             AS listed_share_qty
    , CAST(change_share_qty AS int)             AS change_share_qty
    , CAST(total_share_qty_after_change AS int) AS total_share_qty_after_change
    , CAST(created_by AS string)                AS created_by
    , CAST(created_date AS date)                AS created_date
    , CAST(updated_by AS string)                AS updated_by
    , CAST(updated_date AS date)                AS updated_date
    , CAST(delete_flg AS int)                   AS delete_flg
FROM {{ source('source_ids', 'raw_stock_listing_history') }}