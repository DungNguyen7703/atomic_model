/*
*--------------------------------------------------------------------*
* Program code: atm_pc_registration
* Program name: Atomic Pc Registration
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
        , reg_sequence
        , eligibility_date
        , application_submission_date
        , approval_status_cd
        , decision_no
        , decision_date
        , official_letter_no
        , official_letter_date
    FROM {{ ref('ods_ids_pub_company_registration') }}
    WHERE created_date >= TO_TIMESTAMP('{{ var("etl_date") }}')
        AND created_date < TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_PUB_COMPANY_REGISTRATION', "id") }}           AS pc_registration_id
    , CAST(id AS string)                                                                AS pc_registration_code
    , CAST('IDS_PUB_COMPANY_REGISTRATION' AS string)                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(reg_sequence AS int)                                                         AS registration_sequence_nbr
    , CAST(eligibility_date AS date)                                                    AS eligibility_dt
    , CAST(application_submission_date AS date)                                         AS application_submission_dt
    , CAST(approval_status_cd AS string)                                                AS approval_status_code
    , CAST(decision_no AS string)                                                       AS decision_nbr
    , CAST(decision_date AS date)                                                       AS decision_dt
    , CAST(official_letter_no AS string)                                                AS official_letter_nbr
    , CAST(official_letter_date AS date)                                                AS official_letter_dt
FROM src
