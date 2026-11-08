/*
*--------------------------------------------------------------------*
* Program code: ods_ids_legal_entities
* Program name: ODS IDS.LEGAL_ENTITIES
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
    , entity_name
    , entity_type_cd
    , identity_type_cd
    , business_reg_no
    , address
    , phone_no
    , fax_no
    , gender_cd
    , education_level_cd
    , nationality
    , birth_date
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , first_reg_date
    , paid_up_charter_capital
    , website
    , business_sector
FROM {{ ref('stg_ids_legal_entities') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')