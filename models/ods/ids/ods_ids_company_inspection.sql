/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_inspection
* Program name: ODS IDS.COMPANY_INSPECTION
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
    , inspection_type_cd
    , decision_no
    , decision_date
    , inspection_period
    , inspection_date
    , inspection_mode_cd
    , inspection_scope
    , lead_inspection_unit_vi
    , lead_inspection_unit_en
    , inspection_minutes_name
    , inspection_file_url
    , sanction_decision_no
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_ids_company_inspection') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')