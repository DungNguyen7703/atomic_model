/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_relationship
* Program name: ODS IDS.COMPANY_RELATIONSHIP
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
    , relationship_type_cd
    , full_name_vi
    , full_name_en
    , business_reg_no
    , head_office_addr
    , related_party_info
    , paid_in_capital
    , owned_share_qty
    , ownership_ratio
    , voting_share_ratio
    , effective_from_date
    , effective_to_date
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , is_sync
FROM {{ ref('stg_ids_company_relationship') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')