/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_add_capital
* Program name: ODS IDS.COMPANY_ADD_CAPITAL
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
    , report_year
    , paid_in_capital_eofy
    , capital_increase_am
    , capital_increase_count
    , capital_increase_purpose
    , official_letter_no
    , official_letter_date
    , licensing_authority_vi
    , licensing_authority_en
    , delete_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , is_sync
FROM {{ ref('stg_ids_company_add_capital') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')