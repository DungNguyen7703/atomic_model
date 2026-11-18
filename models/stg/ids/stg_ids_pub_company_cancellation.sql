/*
*--------------------------------------------------------------------*
* Program code: stg_ids_pub_company_cancellation
* Program name: Staging IDS.PUB_COMPANY_CANCELLATION
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
    , CAST(cancel_type_cd AS string)                    AS cancel_type_cd
    , CAST(cancellation_date AS date)                   AS cancellation_date
    , CAST(application_submission_date AS date)         AS application_submission_date
    , CAST(eligibility_date_after_cancellation AS date) AS eligibility_date_after_cancellation
    , CAST(approval_status_cd AS string)                AS approval_status_cd
    , CAST(decision_no AS string)                       AS decision_no
    , CAST(decision_date AS date)                       AS decision_date
    , CAST(created_date AS timestamp)                   AS created_date
    , CAST(created_by AS string)                        AS created_by
    , CAST(updated_date AS timestamp)                   AS updated_date
    , CAST(updated_by AS string)                        AS updated_by
    , CAST(delete_flg AS int)                           AS delete_flg
    , CAST(official_letter_no AS string)                AS official_letter_no
    , CAST(official_letter_date AS date)                AS official_letter_date
FROM {{ source('source_ids', 'raw_pub_company_cancellation') }}