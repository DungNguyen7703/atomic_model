/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_relationship
* Program name: Staging IDS.COMPANY_RELATIONSHIP
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                             AS id
    , CAST(company_profile_id AS int)           AS company_profile_id
    , CAST(relationship_type_cd AS string)      AS relationship_type_cd
    , CAST(full_name_vi AS string)              AS full_name_vi
    , CAST(full_name_en AS string)              AS full_name_en
    , CAST(business_reg_no AS string)           AS business_reg_no
    , CAST(head_office_addr AS string)          AS head_office_addr
    , CAST(related_party_info AS string)        AS related_party_info
    , CAST(paid_in_capital AS int)              AS paid_in_capital
    , CAST(owned_share_qty AS int)              AS owned_share_qty
    , CAST(ownership_ratio AS decimal(19,6))    AS ownership_ratio
    , CAST(voting_share_ratio AS decimal(19,6)) AS voting_share_ratio
    , CAST(effective_from_date AS date)         AS effective_from_date
    , CAST(effective_to_date AS date)           AS effective_to_date
    , CAST(created_by AS string)                AS created_by
    , CAST(created_date AS date)                AS created_date
    , CAST(updated_by AS string)                AS updated_by
    , CAST(updated_date AS date)                AS updated_date
    , CAST(delete_flg AS int)                   AS delete_flg
    , CAST(is_sync AS int)                      AS is_sync
FROM {{ source('source_ids', 'raw_company_relationship') }}