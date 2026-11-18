/*
*--------------------------------------------------------------------*
* Program code: stg_ids_legal_entities
* Program name: Staging IDS.LEGAL_ENTITIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(entity_name AS string)          AS entity_name
    , CAST(entity_type_cd AS string)       AS entity_type_cd
    , CAST(identity_type_cd AS string)     AS identity_type_cd
    , CAST(business_reg_no AS string)      AS business_reg_no
    , CAST(address AS string)              AS address
    , CAST(phone_no AS string)             AS phone_no
    , CAST(fax_no AS string)               AS fax_no
    , CAST(gender_cd AS string)            AS gender_cd
    , CAST(education_level_cd AS string)   AS education_level_cd
    , CAST(nationality AS string)          AS nationality
    , CAST(birth_date AS date)             AS birth_date
    , CAST(created_by AS string)           AS created_by
    , CAST(created_date AS date)           AS created_date
    , CAST(updated_by AS string)           AS updated_by
    , CAST(updated_date AS date)           AS updated_date
    , CAST(delete_flg AS int)              AS delete_flg
    , CAST(first_reg_date AS date)         AS first_reg_date
    , CAST(paid_up_charter_capital AS int) AS paid_up_charter_capital
    , CAST(website AS string)              AS website
    , CAST(business_sector AS string)      AS business_sector
FROM {{ source('source_ids', 'raw_legal_entities') }}