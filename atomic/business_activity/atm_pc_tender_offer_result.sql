/*
*--------------------------------------------------------------------*
* Program code: atm_pc_tender_offer_result
* Program name: Atomic Pc Tender Offer Result
* Created by:
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , company_tender_offer_id
        , registered_sale_share_qty
        , registered_sale_investor_qty
        , actual_purchased_share_qty
        , actual_purchased_investor_qty
        , total_funding_am
        , post_offer_share_qty
        , post_offer_ownership_ratio
        , actual_offer_end_date
        , securities_agent_name_vi
        , securities_agent_name_en
        , certificate_no
        , certificate_date
        , official_letter_no
        , official_letter_date
        , approval_status_cd
        , revision_reason
        , offering_phase_name
        , approver_comment
    FROM {{ ref('ods_ids_company_tender_offer_result') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_TENDER_OFFER_RESULT', "id") }}                 AS pc_tender_offer_result_id
    , CAST(id AS string)                                                                         AS pc_tender_offer_result_code
    , CAST('IDS_COMPANY_TENDER_OFFER_RESULT' AS string)                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_TENDER_OFFER', "company_tender_offer_id") }} AS pc_tender_offer_id
    , CAST(company_tender_offer_id AS string)                                                    AS pc_tender_offer_code
    , CAST(registered_sale_share_qty AS bigint)                                                  AS registered_sale_share_quantity
    , CAST(registered_sale_investor_qty AS int)                                                  AS registered_sale_investor_quantity
    , CAST(actual_purchased_share_qty AS bigint)                                                 AS actual_purchased_share_quantity
    , CAST(actual_purchased_investor_qty AS int)                                                 AS actual_purchased_investor_quantity
    , CAST(total_funding_am AS decimal(23,2))                                                    AS total_funding_amt
    , CAST(post_offer_share_qty AS bigint)                                                       AS post_offer_share_quantity
    , CAST(post_offer_ownership_ratio AS decimal(5,2))                                           AS post_offer_ownership_ratio_percentage
    , CAST(actual_offer_end_date AS date)                                                        AS actual_offer_end_dt
    , CAST(securities_agent_name_vi AS string)                                                   AS securities_agent_nm
    , CAST(securities_agent_name_en AS string)                                                   AS securities_agent_english_nm
    , CAST(certificate_no AS string)                                                             AS certificate_nbr
    , CAST(certificate_date AS date)                                                             AS certificate_dt
    , CAST(official_letter_no AS string)                                                         AS official_letter_nbr
    , CAST(official_letter_date AS date)                                                         AS official_letter_dt
    , CAST(approval_status_cd AS string)                                                         AS approval_status_code
    , CAST(revision_reason AS string)                                                            AS revision_reason
    , CAST(offering_phase_name AS string)                                                        AS offering_phase_nm
    , CAST(approver_comment AS string)                                                           AS approver_comment
FROM src
