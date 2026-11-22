/*
*--------------------------------------------------------------------*
* Program code: atm_pc_tender_offer
* Program name: Atomic Pc Tender Offer
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
        , company_profile_id
        , target_company_name_vi
        , target_company_name_en
        , target_equity_ticker
        , target_listing_exch
        , target_ho_addr
        , target_website
        , target_charter_capital
        , target_share_type
        , relationship_with_target
        , pre_offer_share_qty
        , pre_offer_ownership_ratio
        , planned_offer_share_qty
        , planned_offer_share_ratio
        , planned_offer_price
        , planned_total_value
        , funding_source
        , payment_terms_and_method
        , planned_offer_from_date
        , planned_offer_to_date
        , securities_agent_name_vi
        , securities_agent_name_en
        , application_cd
        , administrative_proc_cd
        , certificate_no
        , certificate_date
        , official_letter_no
        , official_letter_date
        , approval_status_cd
        , revision_reason
        , submission_date
        , approver_comment
        , administrative_status_cd
    FROM {{ ref('ods_ids_company_tender_offer') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_TENDER_OFFER', "id") }}               AS pc_tender_offer_id
    , CAST(id AS string)                                                                AS pc_tender_offer_code
    , CAST('IDS_COMPANY_TENDER_OFFER' AS string)                                        AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(target_company_name_vi AS string)                                            AS target_company_nm
    , CAST(target_company_name_en AS string)                                            AS target_company_english_nm
    , CAST(securities_agent_name_vi AS string)                                          AS securities_agent_nm
    , CAST(securities_agent_name_en AS string)                                          AS securities_agent_english_nm
    , CAST(relationship_with_target AS string)                                          AS rltnp_with_target
    , CAST(planned_offer_from_date AS date)                                             AS planned_offer_from_dt
    , CAST(planned_offer_to_date AS date)                                               AS planned_offer_to_dt
    , CAST(pre_offer_share_qty AS bigint)                                               AS pre_offer_share_quantity
    , CAST(pre_offer_ownership_ratio AS decimal(5,2))                                   AS pre_offer_ownership_ratio_percentage
    , CAST(planned_offer_share_qty AS bigint)                                           AS planned_offer_share_quantity
    , CAST(planned_offer_share_ratio AS decimal(5,2))                                   AS planned_offer_share_ratio_percentage
    , CAST(planned_offer_price AS decimal(23,2))                                        AS planned_offer_price_amt
    , CAST(target_equity_ticker AS string)                                              AS target_equity_ticker
    , CAST(target_listing_exch AS string)                                               AS exchange_code
    , CAST(target_ho_addr AS string)                                                    AS target_head_office_adr
    , CAST(target_website AS string)                                                    AS target_website
    , CAST(target_charter_capital AS decimal(23,2))                                     AS target_charter_capital_amt
    , CAST(target_share_type AS string)                                                 AS target_share_tp
    , CAST(planned_total_value AS decimal(23,2))                                        AS planned_total_val_amt
    , CAST(funding_source AS string)                                                    AS funding_src_description
    , CAST(payment_terms_and_method AS string)                                          AS payment_terms_and_method_description
    , CAST(application_cd AS string)                                                    AS application_code
    , CAST(administrative_proc_cd AS string)                                            AS ap_code
    , CAST(certificate_no AS string)                                                    AS certificate_nbr
    , CAST(certificate_date AS date)                                                    AS certificate_dt
    , CAST(official_letter_no AS string)                                                AS official_letter_nbr
    , CAST(official_letter_date AS date)                                                AS official_letter_dt
    , CAST(approval_status_cd AS string)                                                AS approval_status_code
    , CAST(revision_reason AS string)                                                   AS revision_reason
    , CAST(approver_comment AS string)                                                  AS approver_comment
    , CAST(submission_date AS date)                                                     AS submission_dt
    , CAST(administrative_status_cd AS string)                                          AS administrative_status_code
FROM src
