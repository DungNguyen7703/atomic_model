/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_shareholding
* Program name: ODS IDS.COMPANY_SHAREHOLDING
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
    , legal_entity_id
    , founder_hld_flg
    , founder_hld_active_date
    , founder_hld_inactive_date
    , major_hld_flg
    , major_hld_active_date
    , major_hld_inactive_date
    , strategic_hld_flg
    , strategic_hld_active_date
    , strategic_hld_inactive_date
    , insider_hld_flg
    , insider_hld_active_date
    , insider_hld_inactive_date
    , government_hld_flg
    , government_hld_active_date
    , government_hld_inactive_date
    , related_hld_flg
    , related_hld_active_date
    , related_hld_inactive_date
    , other_hld_flg
    , other_hld_active_date
    , other_hld_inactive_date
    , shareholder_type
    , ownership_qty
    , ownership_ratio
    , ownership_date
    , description
    , approval_flg
    , data_source_cd
    , data_updated_date
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_ids_company_shareholding') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')