/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_application_group
* Program name: Atomic Securities Practitioner License Application Group
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Tao model theo LLD NHNCK_APPLICATION_GROUPS.
*--------------------------------------------------------------------*
*/

WITH ap_gr AS (
    SELECT
        id
        , group_name
        , description
        , status
        , decision_id
        , group_created_date
        , group_completed_date
        , notes
        , application_count
        , application_type
        , submited_date
        , submited_by
    FROM {{ ref('ods_nhnck_application_groups') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_APPLICATION_GROUPS', "ap_gr.id") }} AS sp_license_application_group_id
    , CAST(ap_gr.id AS string)                                                    AS sp_license_application_group_code
    , CAST('NHNCK_APPLICATION_GROUPS' AS string)                                  AS src_stm_code
    , CAST(ap_gr.group_name AS string)                                            AS group_nm
    , CAST(ap_gr.description AS string)                                           AS description
    , {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "ap_gr.decision_id") }} AS sp_license_decision_document_id
    , CAST(ap_gr.decision_id AS string)                                           AS sp_license_decision_document_code
    , CAST(ap_gr.group_created_date AS date)                                      AS group_created_dt
    , CAST(ap_gr.group_completed_date AS date)                                    AS group_completed_dt
    , CAST(ap_gr.notes AS string)                                                 AS notes
    , CAST(ap_gr.application_count AS int)                                        AS application_count
    , CAST(ap_gr.application_type AS string)                                      AS application_tp_code
    , CAST(ap_gr.submited_date AS date)                                           AS submitted_dt
    , {{ generate_surrogate_key_bigint('IAM_USERS', "ap_gr.submited_by") }}       AS submitted_by_officer_id
    , CAST(ap_gr.submited_by AS string)                                           AS submitted_by_officer_code
    , CAST(ap_gr.status AS string)                                                AS status_code
FROM ap_gr