/*
*--------------------------------------------------------------------*
* Program code: atm_stock_holder_trading_account
* Program name: Atomic Stock Holder Trading Account
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , trading_account_no
        , sec_company_cd
        , legal_entity_id
        , account_open_date
        , primary_account_flg
    FROM {{ ref('ods_ids_account_numbers') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_ACCOUNT_NUMBERS', "id") }}               AS stock_holder_trading_account_id
    , CAST(id AS string)                                                           AS stock_holder_trading_account_code
    , CAST('IDS_ACCOUNT_NUMBERS' AS string)                                        AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "legal_entity_id") }} AS legal_entity_id
    , CAST(legal_entity_id AS string)                                              AS legal_entity_code
    , CAST(trading_account_no AS string)                                           AS trading_account_nbr
    , CAST(sec_company_cd AS string)                                               AS sc_code
    , CAST(account_open_date AS date)                                              AS account_open_dt
    , CAST(primary_account_flg AS int)                                             AS primary_account_ind
FROM src
