/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_application_fee
* Program name: Atomic Securities Practitioner License Application Fee
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ap_fe AS (
    SELECT
        id
        , application_id
        , professional_id
        , fee_type
        , content
        , fee
        , request_date
        , payment_date
        , expiry_date
        , file_path
        , note
    FROM {{ ref('ods_nhnck_application_fees') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_APPLICATION_FEES', "ap_fe.id") }}             AS sp_license_application_fee_id
    , CAST(ap_fe.id AS string)                                                            AS sp_license_application_fee_code
    , CAST('NHNCK_APPLICATION_FEES' AS string)                                            AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATIONS', "ap_fe.application_id") }}   AS sp_license_application_id
    , CAST(ap_fe.application_id AS string)                                                AS sp_license_application_code
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "ap_fe.professional_id") }} AS sp_id
    , CAST(ap_fe.professional_id AS string)                                               AS sp_code
    , CAST(ap_fe.fee_type AS string)                                                      AS fee_tp_code
    , CAST(ap_fe.content AS string)                                                       AS fee_content
    , CAST(ap_fe.fee AS decimal(23,2))                                                    AS fee_amt
    , CAST(ap_fe.request_date AS date)                                                    AS payment_request_dt
    , CAST(ap_fe.payment_date AS date)                                                    AS payment_dt
    , CAST(ap_fe.expiry_date AS date)                                                     AS payment_expiry_dt
    , CAST(ap_fe.file_path AS string)                                                     AS payment_evidence_file_path
    , CAST(ap_fe.note AS string)                                                          AS note
FROM ap_fe