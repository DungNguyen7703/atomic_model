/*
*--------------------------------------------------------------------*
* Program code: atm_pc_treasury_share_transaction
* Program name: Atomic Pc Treasury Share Transaction
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
        , transaction_type_cd
        , consulting_org
        , audit_org
        , other_org
        , official_letter_no
        , official_letter_date
        , approval_status_cd
        , administrative_status_cd
        , revision_reason
        , total_treasury_share_before
        , latest_treasury_trans_qty
        , latest_treasury_trans_date
        , latest_offering_end_date
        , total_registered_trans_qty
        , par_value
        , treasury_trans_purpose
        , planned_trans_start_date
        , planned_trans_end_date
        , transaction_method
        , pricing_method
        , daily_trans_qty
        , min_trans_price
        , max_trans_price
        , securities_agent_name_vi
        , securities_agent_name_en
        , securities_agent_addr
        , securities_agent_phone
        , certificate_no
        , certificate_date
        , administrative_proc_cd
        , application_cd
        , submission_date
        , approver_comment
        , funding_source
    FROM {{ ref('ods_ids_company_treasury_shares') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_TREASURY_SHARES', "id") }}            AS pc_treasury_share_transaction_id
    , CAST(id AS string)                                                                AS pc_treasury_share_transaction_code
    , CAST('IDS_COMPANY_TREASURY_SHARES' AS string)                                     AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(transaction_type_cd AS string)                                               AS transaction_tp_code
    , CAST(consulting_org AS string)                                                    AS consulting_organization_nm
    , CAST(audit_org AS string)                                                         AS audit_organization_nm
    , CAST(other_org AS string)                                                         AS other_organization_nm
    , CAST(official_letter_no AS string)                                                AS official_letter_nbr
    , CAST(official_letter_date AS date)                                                AS official_letter_dt
    , CAST(approval_status_cd AS string)                                                AS approval_status_code
    , CAST(administrative_status_cd AS string)                                          AS administrative_status_code
    , CAST(revision_reason AS string)                                                   AS revision_reason
    , CAST(total_treasury_share_before AS bigint)                                       AS total_treasury_share_before_quantity
    , CAST(latest_treasury_trans_qty AS bigint)                                         AS latest_treasury_transaction_quantity
    , CAST(latest_treasury_trans_date AS date)                                          AS latest_treasury_transaction_dt
    , CAST(latest_offering_end_date AS date)                                            AS latest_offering_end_dt
    , CAST(total_registered_trans_qty AS bigint)                                        AS total_registered_transaction_quantity
    , CAST(par_value AS decimal(23,2))                                                  AS par_val_amt
    , CAST(treasury_trans_purpose AS string)                                            AS treasury_transaction_purpose
    , CAST(funding_source AS decimal(23,2))                                             AS funding_src_description
    , CAST(planned_trans_start_date AS date)                                            AS planned_transaction_start_dt
    , CAST(planned_trans_end_date AS date)                                              AS planned_transaction_end_dt
    , CAST(transaction_method AS string)                                                AS transaction_method
    , CAST(pricing_method AS string)                                                    AS pricing_method
    , CAST(daily_trans_qty AS bigint)                                                   AS daily_transaction_quantity
    , CAST(min_trans_price AS decimal(23,2))                                            AS minimum_transaction_price_amt
    , CAST(max_trans_price AS decimal(23,2))                                            AS maximum_transaction_price_amt
    , CAST(securities_agent_name_vi AS string)                                          AS securities_agent_nm
    , CAST(securities_agent_name_en AS string)                                          AS securities_agent_english_nm
    , CAST(securities_agent_addr AS string)                                             AS securities_agent_adr
    , CAST(securities_agent_phone AS string)                                            AS securities_agent_phone_nbr
    , CAST(certificate_no AS string)                                                    AS certificate_nbr
    , CAST(certificate_date AS date)                                                    AS certificate_dt
    , CAST(administrative_proc_cd AS string)                                            AS ap_code
    , CAST(application_cd AS string)                                                    AS application_code
    , CAST(approver_comment AS string)                                                  AS approver_comment
    , CAST(submission_date AS date)                                                     AS submission_dt
FROM src
