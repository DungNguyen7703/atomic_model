/*
*--------------------------------------------------------------------*
* Program code: atm_pc_cancellation
* Program name: Atomic Pc Cancellation
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
        , cancel_type_cd
        , cancellation_date
        , application_submission_date
        , eligibility_date_after_cancellation
        , approval_status_cd
        , decision_no
        , decision_date
        , official_letter_no
        , official_letter_date
    FROM {{ ref('ods_ids_pub_company_cancellation') }}
    WHERE created_date >= TO_TIMESTAMP('{{ var("etl_date") }}')
        AND created_date < TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_PUB_COMPANY_CANCELLATION', "id") }}           AS pc_cancellation_id
    , CAST(id AS string)                                                                AS pc_cancellation_code
    , CAST('IDS_PUB_COMPANY_CANCELLATION' AS string)                                    AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(cancel_type_cd AS string)                                                    AS cancellation_tp_code
    , CAST(cancellation_date AS date)                                                   AS cancellation_dt
    , CAST(application_submission_date AS date)                                         AS application_submission_dt
    , CAST(eligibility_date_after_cancellation AS date)                                 AS eligibility_dt_after_cancellation
    , CAST(approval_status_cd AS string)                                                AS approval_status_code
    , CAST(decision_no AS string)                                                       AS decision_nbr
    , CAST(decision_date AS date)                                                       AS decision_dt
    , CAST(official_letter_no AS string)                                                AS official_letter_nbr
    , CAST(official_letter_date AS date)                                                AS official_letter_dt
FROM src
