/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_certificate_group
* Program name: Atomic Securities Practitioner License Certificate Group
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Tao model theo LLD NHNCK_CERTIFICATE_RECORD_GROUPS.
*--------------------------------------------------------------------*
*/

WITH ce_re_gr AS (
    SELECT
        id
        , group_name
        , description
        , status
        , type
        , decision_id
        , group_created_date
        , group_completed_date
        , notes
        , certificate_record_count
    FROM {{ ref('ods_nhnck_certificate_record_groups') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATE_RECORD_GROUPS', "ce_re_gr.id") }} AS sp_license_certificate_group_id
    , CAST(ce_re_gr.id AS string)                                                           AS sp_license_certificate_group_code
    , CAST('NHNCK_CERTIFICATE_RECORD_GROUPS' AS string)                                     AS src_stm_code
    , CAST(ce_re_gr.group_name AS string)                                                   AS group_nm
    , CAST(ce_re_gr.description AS string)                                                  AS description
    , CAST(ce_re_gr.type AS string)                                                         AS group_tp_code
    , {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "ce_re_gr.decision_id") }}        AS sp_license_decision_document_id
    , CAST(ce_re_gr.decision_id AS string)                                                  AS sp_license_decision_document_code
    , CAST(ce_re_gr.group_created_date AS date)                                             AS group_created_dt
    , CAST(ce_re_gr.group_completed_date AS date)                                           AS group_completed_dt
    , CAST(ce_re_gr.notes AS string)                                                        AS notes
    , CAST(ce_re_gr.certificate_record_count AS int)                                        AS certificate_record_count
    , CAST(ce_re_gr.status AS string)                                                       AS status_code
FROM ce_re_gr