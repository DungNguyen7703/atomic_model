/*
*--------------------------------------------------------------------*
* Program code: stg_ids_tender_offer
* Program name: Staging IDS.TENDER_OFFER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                                 AS id
    , CAST(company_profile_id AS int)                 AS company_profile_id
    , CAST(target_company_name_vi AS string)          AS target_company_name_vi
    , CAST(target_company_name_en AS string)          AS target_company_name_en
    , CAST(target_equity_ticker AS string)            AS target_equity_ticker
    , CAST(target_listing_exch AS string)             AS target_listing_exch
    , CAST(target_ho_addr AS string)                  AS target_ho_addr
    , CAST(target_website AS string)                  AS target_website
    , CAST(target_charter_capital AS decimal(24,0))   AS target_charter_capital
    , CAST(target_share_type AS string)               AS target_share_type
    , CAST(relationship_with_target AS string)        AS relationship_with_target
    , CAST(pre_offer_share_qty AS bigint)             AS pre_offer_share_qty
    , CAST(pre_offer_ownership_ratio AS decimal(5,2)) AS pre_offer_ownership_ratio
    , CAST(planned_offer_share_qty AS bigint)         AS planned_offer_share_qty
    , CAST(planned_offer_share_ratio AS decimal(5,2)) AS planned_offer_share_ratio
    , CAST(planned_offer_price AS decimal(19,0))      AS planned_offer_price
    , CAST(planned_total_value AS decimal(24,0))      AS planned_total_value
    , CAST(funding_source AS string)                  AS funding_source
    , CAST(payment_terms_and_method AS string)        AS payment_terms_and_method
    , CAST(planned_offer_from_date AS date)           AS planned_offer_from_date
    , CAST(planned_offer_to_date AS date)             AS planned_offer_to_date
    , CAST(securities_agent_name_vi AS string)        AS securities_agent_name_vi
    , CAST(securities_agent_name_en AS string)        AS securities_agent_name_en
    , CAST(application_cd AS string)                  AS application_cd
    , CAST(administrative_proc_cd AS string)          AS administrative_proc_cd
    , CAST(certificate_no AS string)                  AS certificate_no
    , CAST(certificate_date AS date)                  AS certificate_date
    , CAST(official_letter_no AS string)              AS official_letter_no
    , CAST(official_letter_date AS date)              AS official_letter_date
    , CAST(approval_status_cd AS string)              AS approval_status_cd
    , CAST(approver_user_id AS string)                AS approver_user_id
    , CAST(approver_user_name AS string)              AS approver_user_name
    , CAST(processor_user_id AS string)               AS processor_user_id
    , CAST(processor_user_name AS string)             AS processor_user_name
    , CAST(revision_reason AS string)                 AS revision_reason
    , CAST(created_by AS string)                      AS created_by
    , CAST(created_date AS date)                      AS created_date
    , CAST(updated_by AS string)                      AS updated_by
    , CAST(updated_date AS date)                      AS updated_date
    , CAST(delete_flg AS int)                         AS delete_flg
    , CAST(administrative_status_cd AS string)        AS administrative_status_cd
FROM {{ source('source_ids', 'raw_tender_offer') }}