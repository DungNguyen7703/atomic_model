/*
*--------------------------------------------------------------------*
* Program code: stg_ids_account_numbers
* Program name: Staging IDS.ACCOUNT_NUMBERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                      AS id
    , CAST(trading_account_no AS string) AS trading_account_no
    , CAST(sec_company_cd AS string)     AS sec_company_cd
    , CAST(legal_entity_id AS int)       AS legal_entity_id
    , CAST(account_open_date AS date)    AS account_open_date
    , CAST(active_flg AS int)            AS active_flg
    , CAST(primary_account_flg AS int)   AS primary_account_flg
    , CAST(created_by AS string)         AS created_by
    , CAST(created_date AS date)         AS created_date
    , CAST(updated_by AS string)         AS updated_by
    , CAST(updated_date AS date)         AS updated_date
    , CAST(delete_flg AS int)            AS delete_flg
FROM {{ source('source_ids', 'raw_account_numbers') }}