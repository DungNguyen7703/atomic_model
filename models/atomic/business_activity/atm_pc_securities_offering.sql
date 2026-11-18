/*
*--------------------------------------------------------------------*
* Program code: atm_pc_securities_offering
* Program name: Atomic Public Company Securities Offering
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH se_of AS (
    SELECT
        id
        , applicant_type_flg
        , company_profile_id
        , legal_entity_id
        , application_cd
        , administrative_proc_cd
        , administrative_status_cd
        , certificate_no
        , certificate_date
        , official_letter_no
        , official_letter_date
        , offering_purpose
        , total_registered_qty
        , total_expected_am
        , capital_usage_plan
        , expected_schedule
        , matching_capital
        , consulting_org
        , audit_org
        , bond_representative_org
        , underwwriting_org
        , credit_rating_org
        , other_org
        , approval_status_cd
        , approver_user_id
        , approver_user_name
        , processor_user_id
        , processor_user_name
        , revision_reason
        , multi_turn_flg
        , is_sync
        , delete_flg
        , approver_comment
        , submission_date
        , project_investment_flg
        , capital_purpose
    FROM {{ ref('ods_ids_securities_offering') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_SECURITIES_OFFERING', "se_of.id") }}                AS pc_securities_offering_id
    , CAST(se_of.id AS string)                                                                AS pc_securities_offering_code
    , CAST('IDS_SECURITIES_OFFERING' AS string)                                               AS src_stm_code
    , CAST(se_of.applicant_type_flg AS int)                                                   AS applicant_tp_ind
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "se_of.company_profile_id") }} AS pc_id
    , CAST(se_of.company_profile_id AS string)                                                AS pc_code
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "se_of.legal_entity_id") }}      AS legal_entity_id
    , CAST(se_of.legal_entity_id AS string)                                                   AS legal_entity_code
    , CAST(se_of.application_cd AS string)                                                    AS application_code
    , CAST(se_of.administrative_proc_cd AS string)                                            AS administrative_procedure_code
    , CAST(se_of.administrative_status_cd AS string)                                          AS administrative_status_code
    , CAST(se_of.certificate_no AS string)                                                    AS certificate_nbr
    , CAST(se_of.certificate_date AS date)                                                    AS certificate_dt
    , CAST(se_of.official_letter_no AS string)                                                AS official_letter_nbr
    , CAST(se_of.official_letter_date AS date)                                                AS official_letter_dt
    , CAST(se_of.offering_purpose AS string)                                                  AS offering_purpose
    , CAST(se_of.total_registered_qty AS int)                                                 AS total_registered_quantity
    , CAST(se_of.total_expected_am AS decimal(23,2))                                          AS total_expected_amt
    , CAST(se_of.capital_usage_plan AS string)                                                AS capital_usage_plan
    , CAST(se_of.expected_schedule AS string)                                                 AS expected_schedule
    , CAST(se_of.matching_capital AS string)                                                  AS matching_capital_src
    , CAST(se_of.consulting_org AS string)                                                    AS consulting_organization_nm
    , CAST(se_of.audit_org AS string)                                                         AS audit_organization_nm
    , CAST(se_of.bond_representative_org AS string)                                           AS bond_representative_organization_nm
    , CAST(se_of.underwwriting_org AS string)                                                 AS underwriting_organization_nm
    , CAST(se_of.credit_rating_org AS string)                                                 AS credit_rating_organization_nm
    , CAST(se_of.other_org AS string)                                                         AS other_related_organization_nm
    , CAST(se_of.approval_status_cd AS string)                                                AS approval_status_code
    , {{ generate_surrogate_key_bigint('IAM_USERS', "se_of.approver_user_id") }}              AS approver_user_id
    , CAST(se_of.approver_user_id AS string)                                                  AS approver_user_code
    , CAST(se_of.approver_user_name AS string)                                                AS approver_user_nm_snpst
    , {{ generate_surrogate_key_bigint('IAM_USERS', "se_of.processor_user_id") }}             AS processor_user_id
    , CAST(se_of.processor_user_id AS string)                                                 AS processor_user_code
    , CAST(se_of.processor_user_name AS string)                                               AS processor_user_nm_snpst
    , CAST(se_of.revision_reason AS string)                                                   AS revision_reason
    , CAST(se_of.multi_turn_flg AS int)                                                       AS multi_turn_ind
    , CAST(se_of.is_sync AS int)                                                              AS synced_from_external_stm_ind
    , CAST(se_of.delete_flg AS int)                                                           AS deleted_ind
    , CAST(se_of.approver_comment AS string)                                                  AS approver_comment
    , CAST(se_of.submission_date AS date)                                                     AS submission_dt
    , CAST(se_of.project_investment_flg AS int)                                               AS project_investment_ind
    , CAST(se_of.capital_purpose AS string)                                                   AS capital_purpose
FROM se_of