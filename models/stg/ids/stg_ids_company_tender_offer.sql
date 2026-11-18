/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_tender_offer
* Program name: Staging IDS.COMPANY_TENDER_OFFER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                                     AS id
    , CAST(company_profile_id AS int)                   AS company_profile_id
    , CAST(target_company_name_vi AS string)            AS tender_offeror_name_vi
    , CAST(target_company_name_en AS string)            AS tender_offeror_name_en
    , CAST(securities_agent_name_vi AS string)          AS securities_agent_name_vi
    , CAST(securities_agent_name_en AS string)          AS securities_agent_name_en
    , CAST(null AS string)                              AS offeror_id_no
    , CAST(relationship_with_target AS string)          AS offeror_relationship
    , CAST(planned_offer_from_date AS date)             AS planned_offer_from_date
    , CAST(planned_offer_to_date AS date)               AS planned_offer_to_date
    , CAST(pre_offer_share_qty AS int)                  AS pre_offer_share_qty
    , CAST(pre_offer_ownership_ratio AS decimal(8,6))   AS pre_offer_share_ratio
    , CAST(planned_offer_share_qty AS int)              AS planned_offer_share_qty
    , CAST(planned_offer_share_ratio AS decimal(8,6))   AS planned_offer_share_ratio
    , CAST(planned_offer_price AS int)                  AS planned_offer_price
    , CAST(null AS int)                                 AS acquired_share_qty
    , CAST(null AS decimal(8,6))                        AS acquired_share_ratio
    , CAST(null AS int)                                 AS post_offer_share_qty
    , CAST(null AS decimal(8,6))                        AS post_offer_share_ratio
    , CAST(created_by AS string)                        AS created_by
    , CAST(created_date AS date)                        AS created_date
    , CAST(updated_by AS string)                        AS updated_by
    , CAST(updated_date AS date)                        AS updated_date
    , CAST(delete_flg AS int)                           AS delete_flg
    , CAST(null AS int)                                 AS id_sync
FROM {{ source('source_ids', 'raw_company_tender_offer') }}