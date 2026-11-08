/*
*--------------------------------------------------------------------*
* Program code: atm_legal_entity
* Program name: Atomic Legal Entity IDS.LEGAL_ENTITIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-15		tuan.nguyenvanb		[LLD GSTT] Sinh moi - LLD
*                                       DTM_GSTT_opr_public_company_shareholding
*                                       can Legal Entity Name (JOIN theo
*                                       legal_entity_id) nhung atomic model
*                                       chua ton tai du atm_legal_entity_position
*                                       da denormalize legal_entity_id/code.
*                                       Nguon ods_ids_legal_entities/stg da co
*                                       san, tao model theo dung pattern
*                                       atm_public_company (scd4a, filter
*                                       delete_flg != 1).
*--------------------------------------------------------------------*
*/

WITH le AS (
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
        , first_reg_date
        , paid_up_charter_capital
        , website
        , business_sector
        , delete_flg
    FROM {{ ref('ods_ids_legal_entities') }}
    WHERE delete_flg != 1
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "le.id") }}    AS legal_entity_id
    , CAST(le.id AS string)                                              AS legal_entity_code
    , CAST('IDS_LEGAL_ENTITIES' AS string)                               AS src_stm_code
    , CAST(le.entity_name AS string)                                     AS legal_entity_nm
    , CAST(le.entity_type_cd AS string)                                  AS entity_tp_code
    , CAST(le.identity_type_cd AS string)                                AS identity_tp_code
    , CAST(le.business_reg_no AS string)                                 AS business_registration_no
    , CAST(le.address AS string)                                         AS address_val
    , CAST(le.phone_no AS string)                                        AS phone_no
    , CAST(le.fax_no AS string)                                          AS fax_no
    , CAST(le.gender_cd AS string)                                       AS gender_code
    , CAST(le.education_level_cd AS string)                              AS education_level_code
    , CAST(le.nationality AS string)                                     AS nationality_code
    , CAST(le.birth_date AS date)                                        AS birth_dt
    , CAST(le.first_reg_date AS date)                                    AS first_registration_dt
    , CAST(le.paid_up_charter_capital AS decimal(23,2))                  AS paid_up_charter_capital_amt
    , CAST(le.website AS string)                                         AS website_val
    , CAST(le.business_sector AS string)                                 AS business_sector_code
    , CAST(le.delete_flg AS int)                                         AS deleted_indicator
FROM le
