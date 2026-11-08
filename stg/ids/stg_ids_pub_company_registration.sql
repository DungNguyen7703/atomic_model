/*
*--------------------------------------------------------------------*
* Program code: stg_ids_pub_company_registration
* Program name: Staging IDS.PUB_COMPANY_REGISTRATION
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
    , CAST(reg_sequence AS int)                 AS reg_sequence
    , CAST(eligibility_date AS date)            AS eligibility_date
    , CAST(application_submission_date AS date) AS application_submission_date
    , CAST(approval_status_cd AS string)        AS approval_status_cd
    , CAST(decision_no AS string)               AS decision_no
    , CAST(decision_date AS date)               AS decision_date
    , CAST(created_date AS timestamp)           AS created_date
    , CAST(created_by AS string)                AS created_by
    , CAST(updated_date AS timestamp)           AS updated_date
    , CAST(updated_by AS string)                AS updated_by
    , CAST(delete_flg AS int)                   AS delete_flg
    , CAST(official_letter_no AS string)        AS official_letter_no
    , CAST(official_letter_date AS date)        AS official_letter_date
FROM {{ source('source_ids', 'raw_pub_company_registration') }}