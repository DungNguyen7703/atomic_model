/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_application_status_review
* Program name: Atomic Securities Practitioner License Application Status Review
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Tao model theo LLD NHNCK_VERIFY_APPLICATION_STATUSES.
*--------------------------------------------------------------------*
*/

WITH ve_ap_st AS (
    SELECT
        id
        , application_id
        , status_id
        , prev_status_id
        , status
        , reason
        , spec_reason
        , org_reason
        , overview_reason
        , overview_file_path
        , verified_by
    FROM {{ ref('ods_nhnck_verify_application_statuses') }}
),

appl AS (
    SELECT
        id
        , application_code
    FROM {{ ref('ods_nhnck_applications') }}
),

ap_st AS (
    SELECT
        id
        , status_code
    FROM {{ ref('ods_nhnck_application_statuses') }}
),

ap_st_prev AS (
    SELECT
        id
        , status_code
    FROM {{ ref('ods_nhnck_application_statuses') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_VERIFY_APPLICATION_STATUSES', "ve_ap_st.id") }} AS sp_license_application_status_review_id
    , CAST(ve_ap_st.id AS string)                                                             AS sp_license_application_status_review_code
    , CAST('NHNCK_VERIFY_APPLICATION_STATUSES' AS string)                                     AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATIONS', "appl.application_code") }}      AS sp_license_application_id
    , CAST(appl.application_code AS string)                                                 AS sp_license_application_code
    , CAST(ap_st.status_code AS string)                                                       AS application_status_code
    , CAST(ap_st_prev.status_code AS string)                                                  AS previous_application_status_code
    , CAST(ve_ap_st.reason AS string)                                                         AS review_reason
    , CAST(ve_ap_st.spec_reason AS string)                                                    AS specialized_review_reason
    , CAST(ve_ap_st.org_reason AS string)                                                     AS organization_review_reason
    , CAST(ve_ap_st.overview_reason AS string)                                                AS overview_review_reason
    , CAST(ve_ap_st.overview_file_path AS string)                                             AS overview_attachment_file_path
    , {{ generate_surrogate_key_bigint('IAM_USERS', "ve_ap_st.verified_by") }}                AS verified_by_officer_id
    , CAST(ve_ap_st.verified_by AS string)                                                    AS verified_by_officer_code
    , CAST(ve_ap_st.status AS string)                                                         AS status_code
FROM ve_ap_st
    LEFT JOIN appl ON ve_ap_st.APPLICATION_ID = appl.ID
    LEFT JOIN ap_st ON ve_ap_st.STATUS_ID = ap_st.ID
    LEFT JOIN ap_st_prev ON ve_ap_st.PREV_STATUS_ID = ap_st_prev.ID