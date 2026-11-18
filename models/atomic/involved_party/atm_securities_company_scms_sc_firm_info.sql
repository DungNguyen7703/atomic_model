/*
*--------------------------------------------------------------------*
* Program code: atm_securities_company
* Program name: Atomic Securities Company SCMS.SC_FIRM_INFO
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_in AS (
    SELECT
        code
        , sc_firm_info_id
        , short_name
        , name_vi
        , name_en
        , record_status
        , event_type_id
        , financial_report_type
        , foundation_license_file
        , termination_decision_number
        , charter_capital
        , total_shares
        , business_lines
        , additional_business_lines
        , listed
        , trading_registered
        , listing_exchange
        , securities_code
        , listing_date
        , sc_firm_registration_date
        , official_operation_date
        , fiscal_year_end_date
        , electronic_trading_status
        , electronic_trading_decision_number
        , electronic_trading_decision_date
        , electronic_trading_reason
        , public_company
        , public_company_registration_date
        , public_company_decision_number
        , public_company_end_date
        , public_company_end_decision_number
        , custodian_member_code
        , custodian_membership_revocation_decision
        , custodian_membership_revocation_date
        , foreign_investor_ownership_limit
        , ownership_limit_from_date
        , ownership_limit_to_date
        , amendment_declaration
        , amendment_document_number
        , amendment_document_date
        , amendment_effective_date
        , amendment_expiry_date
        , amendment_document_file
        , provisional
        , synced_from_admin_proc
        , attachment_path
        , note
        , company_type_id
        , id
    FROM {{ ref('ods_scms_sc_firm_info') }}
),

ca_co_ty AS (
    SELECT
        id
        , company_type_code
    FROM {{ ref('ods_scms_cat_company_type') }}
),

ca_sc_fi_st AS (
    SELECT
        id
        , sc_firm_status_code
    FROM {{ ref('ods_scms_cat_sc_firm_status') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                           AS sc_id
    , CAST(sc_fi_in.code AS string)                                                                     AS sc_code
    , CAST('SCMS_SC_FIRM_INFO' AS string)                                                               AS src_stm_code
    , CAST(NULL AS string)                                                                              AS cl_fims_status_id
    , CAST(NULL AS string)                                                                              AS cl_fims_status_code
    , CAST(sc_fi_in.name_vi AS string)                                                                  AS sc_nm
    , CAST(sc_fi_in.name_en AS string)                                                                  AS sc_english_nm
    , CAST(sc_fi_in.short_name AS string)                                                               AS sc_short_nm
    , CAST(NULL AS string)                                                                              AS nationality_id
    , CAST(NULL AS string)                                                                              AS nationality_code
    , CAST(sc_fi_in.charter_capital AS decimal(23,2))                                                   AS charter_capital_amt
    , CAST(NULL AS string)                                                                              AS director_full_nm
    , CAST(NULL AS string)                                                                              AS description
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.sc_firm_info_id") }}              AS parent_sc_id
    , CAST(sc_fi_in.sc_firm_info_id AS string)                                                          AS parent_sc_code
    , CAST(ca_co_ty.company_type_code AS string)                                                        AS company_tp_code
    , {{ generate_surrogate_key_bigint('SCMS_CAT_SC_FIRM_STATUS', "ca_sc_fi_st.sc_firm_status_code") }} AS cl_sc_firm_status_id
    , CAST(ca_sc_fi_st.sc_firm_status_code AS string)                                                   AS cl_sc_firm_status_code
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "sc_fi_in.event_type_id") }}              AS cl_sc_event_tp_id
    , CAST(sc_fi_in.event_type_id AS string)                                                            AS cl_sc_event_tp_code
    , CAST(sc_fi_in.financial_report_type AS string)                                                    AS fr_tp_code
    , CAST(sc_fi_in.foundation_license_file AS string)                                                  AS foundation_license_file_path
    , CAST(sc_fi_in.termination_decision_number AS string)                                              AS termination_decision_nbr
    , CAST(sc_fi_in.total_shares AS decimal(23,2))                                                      AS total_shares
    , CAST(sc_fi_in.business_lines AS string)                                                           AS business_lines
    , CAST(sc_fi_in.additional_business_lines AS string)                                                AS additional_business_lines
    , CAST(sc_fi_in.listed AS int)                                                                      AS listed_ind
    , CAST(sc_fi_in.trading_registered AS int)                                                          AS trading_registered_ind
    , CAST(sc_fi_in.listing_exchange AS string)                                                         AS exchange_code
    , CAST(sc_fi_in.securities_code AS string)                                                          AS securities_code
    , CAST(sc_fi_in.listing_date AS date)                                                               AS listing_dt
    , CAST(sc_fi_in.sc_firm_registration_date AS date)                                                  AS registration_dt
    , CAST(sc_fi_in.official_operation_date AS date)                                                    AS official_operation_dt
    , CAST(sc_fi_in.fiscal_year_end_date AS string)                                                     AS fiscal_year_end_dt
    , CAST(sc_fi_in.electronic_trading_status AS string)                                                AS electronic_trading_status_code
    , CAST(sc_fi_in.electronic_trading_decision_number AS string)                                       AS electronic_trading_decision_nbr
    , CAST(sc_fi_in.electronic_trading_decision_date AS date)                                           AS electronic_trading_decision_dt
    , CAST(sc_fi_in.electronic_trading_reason AS string)                                                AS electronic_trading_reason
    , CAST(sc_fi_in.public_company AS int)                                                              AS pc_ind
    , CAST(sc_fi_in.public_company_registration_date AS date)                                           AS pc_registration_dt
    , CAST(sc_fi_in.public_company_decision_number AS string)                                           AS pc_decision_nbr
    , CAST(sc_fi_in.public_company_end_date AS date)                                                    AS pc_end_dt
    , CAST(sc_fi_in.public_company_end_decision_number AS string)                                       AS pc_end_decision_nbr
    , CAST(sc_fi_in.custodian_member_code AS string)                                                    AS custodian_member_code
    , CAST(sc_fi_in.custodian_membership_revocation_decision AS string)                                 AS custodian_membership_revocation_decision
    , CAST(sc_fi_in.custodian_membership_revocation_date AS date)                                       AS custodian_membership_revocation_dt
    , CAST(sc_fi_in.foreign_investor_ownership_limit AS decimal(5,2))                                   AS foreign_investor_ownership_limit_rate
    , CAST(sc_fi_in.ownership_limit_from_date AS date)                                                  AS ownership_limit_from_dt
    , CAST(sc_fi_in.ownership_limit_to_date AS date)                                                    AS ownership_limit_to_dt
    , CAST(sc_fi_in.amendment_declaration AS int)                                                       AS amendment_declaration_ind
    , CAST(sc_fi_in.amendment_document_number AS string)                                                AS amendment_document_nbr
    , CAST(sc_fi_in.amendment_document_date AS date)                                                    AS amendment_document_dt
    , CAST(sc_fi_in.amendment_effective_date AS date)                                                   AS amendment_effective_dt
    , CAST(sc_fi_in.amendment_expiry_date AS date)                                                      AS amendment_expiry_dt
    , CAST(sc_fi_in.amendment_document_file AS string)                                                  AS amendment_document_file_path
    , CAST(sc_fi_in.provisional AS int)                                                                 AS provisional_ind
    , CAST(sc_fi_in.synced_from_admin_proc AS int)                                                      AS synced_from_admin_process_ind
    , CAST(sc_fi_in.attachment_path AS string)                                                          AS attachment_path
    , CAST(sc_fi_in.note AS string)                                                                     AS note
    , CAST(sc_fi_in.id as bigint) as added_sc_id
FROM sc_fi_in
    LEFT JOIN ca_co_ty ON sc_fi_in.company_type_id = ca_co_ty.id
    LEFT JOIN ca_sc_fi_st ON sc_fi_in.record_status = ca_sc_fi_st.id