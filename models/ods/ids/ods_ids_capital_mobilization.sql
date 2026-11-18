/*
*--------------------------------------------------------------------*
* Program code: ods_ids_capital_mobilization
* Program name: ODS IDS.CAPITAL_MOBILIZATION
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
    , paid_in_capital_eoy
    , capital_increase_count
    , capital_increase_method
    , audit_firm_name_vi
    , audit_firm_name_en
    , delete_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM {{ ref('stg_ids_capital_mobilization') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')