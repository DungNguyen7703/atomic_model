/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_application_result_notification
* Program name: Atomic SP License Application Result Notification
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH ob AS (
    SELECT
        id
        , application_id
        , sender_identity
        , status
        , attempts
        , next_retry_at
        , last_error
    FROM {{ ref('ods_nhnck_mcdt_result_outbox') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_MCDT_RESULT_OUTBOX', "id") }}             AS sp_license_application_result_notification_id
    , CAST(id AS string)                                                              AS sp_license_application_result_notification_code
    , CAST('NHNCK_MCDT_RESULT_OUTBOX' AS string)                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATIONS', "application_id") }}     AS sp_license_application_id
    , CAST(application_id AS string)                                                  AS sp_license_application_code
    , CAST(sender_identity AS string)                                                 AS sender_identity
    , CAST(status AS string)                                                          AS status_code
    , CAST(attempts AS int)                                                           AS attempt_count
    , CAST(next_retry_at AS timestamp)                                                AS next_retry_tms
    , CAST(last_error AS string)                                                      AS last_error_message
FROM ob
