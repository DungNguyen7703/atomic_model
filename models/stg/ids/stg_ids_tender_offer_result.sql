/*
*--------------------------------------------------------------------*
* Program code: stg_ids_tender_offer_result
* Program name: Staging IDS.TENDER_OFFER_RESULT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                                        AS id
    , CAST(tender_offer_id AS int)                           AS tender_offer_id
    , CAST(offering_phase_name AS string)                    AS offering_phase_name
    , CAST(registered_sale_share_qty AS bigint)              AS registered_sale_share_qty
    , CAST(registered_sale_investor_qty AS int)              AS registered_sale_investor_qty
    , CAST(actual_purchased_share_qty AS bigint)             AS actual_purchased_share_qty
    , CAST(actual_purchased_ownership_ratio AS decimal(5,2)) AS actual_purchased_ownership_ratio
    , CAST(actual_purchased_investor_qty AS int)             AS actual_purchased_investor_qty
    , CAST(total_funding_am AS decimal(24,0))                AS total_funding_am
    , CAST(post_offer_share_qty AS bigint)                   AS post_offer_share_qty
    , CAST(post_offer_ownership_ratio AS decimal(5,2))       AS post_offer_ownership_ratio
    , CAST(actual_offer_end_date AS date)                    AS actual_offer_end_date
    , CAST(securities_agent_name_vi AS string)               AS securities_agent_name_vi
    , CAST(securities_agent_name_en AS string)               AS securities_agent_name_en
    , CAST(certificate_no AS string)                         AS certificate_no
    , CAST(certificate_date AS date)                         AS certificate_date
    , CAST(official_letter_no AS string)                     AS official_letter_no
    , CAST(official_letter_date AS date)                     AS official_letter_date
    , CAST(approval_status_cd AS string)                     AS approval_status_cd
    , CAST(approver_user_id AS string)                       AS approver_user_id
    , CAST(approver_user_name AS string)                     AS approver_user_name
    , CAST(processor_user_id AS string)                      AS processor_user_id
    , CAST(processor_user_name AS string)                    AS processor_user_name
    , CAST(revision_reason AS string)                        AS revision_reason
    , CAST(created_by AS string)                             AS created_by
    , CAST(created_date AS date)                             AS created_date
    , CAST(updated_by AS string)                             AS updated_by
    , CAST(updated_date AS date)                             AS updated_date
    , CAST(delete_flg AS int)                                AS delete_flg
FROM {{ source('source_ids', 'raw_tender_offer_result') }}