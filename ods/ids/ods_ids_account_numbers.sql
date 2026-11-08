/*
*--------------------------------------------------------------------*
* Program code: ods_ids_account_numbers
* Program name: ODS IDS.ACCOUNT_NUMBERS
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
    , trading_account_no
    , sec_company_cd
    , legal_entity_id
    , account_open_date
    , active_flg
    , primary_account_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_ids_account_numbers') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')