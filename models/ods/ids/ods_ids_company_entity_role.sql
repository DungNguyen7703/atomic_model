/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_entity_role
* Program name: ODS IDS.COMPANY_ENTITY_ROLE
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
    , role_type_cd
    , active_flg
    , effective_from_date
    , effective_to_date
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_ids_company_entity_role') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')