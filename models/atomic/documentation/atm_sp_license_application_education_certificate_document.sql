/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_application_education_certificate_document
* Program name: Atomic Securities Practitioner License Application Education Certificate Document
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ap_sp AS (
    SELECT
        id
        , application_id
        , specialization_id
        , issue_date
        , issue_place
        , appraisaled_at
        , assignee_id
        , files
        , note
    FROM {{ ref('ods_nhnck_application_specializations') }}
),

appl AS (
    SELECT
        id
        , application_code
    FROM {{ ref('ods_nhnck_applications') }}
),

spec AS (
    SELECT
        id
        , specialization_code
    FROM {{ ref('ods_nhnck_specializations') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_APPLICATION_SPECIALIZATIONS', "ap_sp.id") }}       AS sp_license_application_education_certificate_document_id
    , CAST(ap_sp.id AS string)                                                                 AS sp_license_application_education_certificate_document_code
    , CAST('NHNCK_APPLICATION_SPECIALIZATIONS' AS string)                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATIONS', "appl.application_code") }}       AS sp_license_application_id
    , CAST(ap_sp.application_id AS string)                                                     AS sp_license_application_code
    , {{ generate_surrogate_key_bigint('NHNCK_SPECIALIZATIONS', "spec.specialization_code") }} AS cl_specialization_id
    , CAST(ap_sp.specialization_id AS string)                                                  AS cl_specialization_code
    , CAST(ap_sp.issue_date AS date)                                                           AS certificate_issue_dt
    , CAST(ap_sp.issue_place AS string)                                                        AS certificate_issue_place
    , CAST(ap_sp.appraisaled_at AS timestamp)                                                  AS appraisal_completed_dt
    , {{ generate_surrogate_key_bigint('IAM_USERS', "ap_sp.assignee_id") }}                    AS appraised_by_officer_id
    , CAST(ap_sp.assignee_id AS string)                                                        AS appraised_by_officer_code
    , CAST(ap_sp.files AS string)                                                              AS attachment_files
    , CAST(ap_sp.note AS string)                                                               AS note
FROM ap_sp
    LEFT JOIN appl ON ap_sp.APPLICATION_ID = appl.ID
    LEFT JOIN spec ON ap_sp.SPECIALIZATION_ID = spec.ID