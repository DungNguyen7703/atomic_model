/*
*--------------------------------------------------------------------*
* Program code: stg_ids_securities_offering
* Program name: Staging IDS.SECURITIES_OFFERING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                         AS id
    , CAST(applicant_type_flg AS int)          AS applicant_type_flg
    , CAST(company_profile_id AS bigint)       AS company_profile_id
    , CAST(legal_entity_id AS bigint)          AS legal_entity_id
    , CAST(application_cd AS string)           AS application_cd
    , CAST(administrative_proc_cd AS string)   AS administrative_proc_cd
    , CAST(certificate_no AS string)           AS certificate_no
    , CAST(certificate_date AS date)           AS certificate_date
    , CAST(official_letter_no AS string)       AS official_letter_no
    , CAST(official_letter_date AS date)       AS official_letter_date
    , CAST(offering_purpose AS string)         AS offering_purpose
    , CAST(total_registered_qty AS bigint)     AS total_registered_qty
    , CAST(total_expected_am AS decimal(19,0)) AS total_expected_am
    , CAST(capital_usage_plan AS string)       AS capital_usage_plan
    , CAST(expected_schedule AS string)        AS expected_schedule
    , CAST(matching_capital AS string)         AS matching_capital
    , CAST(consulting_org AS string)           AS consulting_org
    , CAST(audit_org AS string)                AS audit_org
    , CAST(bond_representative_org AS string)  AS bond_representative_org
    , CAST(underwwriting_org AS string)        AS underwwriting_org
    , CAST(credit_rating_org AS string)        AS credit_rating_org
    , CAST(other_org AS string)                AS other_org
    , CAST(approval_status_cd AS string)       AS approval_status_cd
    , CAST(approver_user_id AS string)         AS approver_user_id
    , CAST(approver_user_name AS string)       AS approver_user_name
    , CAST(processor_user_id AS string)        AS processor_user_id
    , CAST(processor_user_name AS string)      AS processor_user_name
    , CAST(revision_reason AS string)          AS revision_reason
    , CAST(multi_turn_flg AS int)              AS multi_turn_flg
    , CAST(is_sync AS int)                     AS is_sync
    , CAST(delete_flg AS int)                  AS delete_flg
    , CAST(created_by AS string)               AS created_by
    , CAST(created_date AS date)               AS created_date
    , CAST(updated_by AS string)               AS updated_by
    , CAST(updated_date AS date)               AS updated_date
    , CAST(submission_date AS date)            AS submission_date
    , CAST(project_investment_flg AS int)      AS project_investment_flg
    , CAST(capital_purpose AS string)          AS capital_purpose
    , CAST(approver_comment AS string)         AS approver_comment
    , CAST(administrative_status_cd AS string)    AS administrative_status_cd
FROM {{ source('source_ids', 'raw_securities_offering') }}