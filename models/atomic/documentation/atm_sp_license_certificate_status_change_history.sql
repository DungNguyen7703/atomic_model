/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_certificate_status_change_history
* Program name: Atomic Securities Practitioner License Certificate Status Change History NHNCK.CERTIFICATE_RECORD_STATUS_HISTORIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ce_re_st_hi AS (
    SELECT
        id
        , created_at
        , certificate_record_id
        , update_type
        , old_status
        , new_status
        , decision_id
        , reason
    FROM {{ ref('ods_nhnck_certificate_record_status_histories') }}
    WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATE_RECORD_STATUS_HISTORIES', "ce_re_st_hi.id") }}      AS sp_license_certificate_status_change_history_id
    , CAST(ce_re_st_hi.id AS string)                                                                        AS sp_license_certificate_status_change_history_code
    , CAST('NHNCK_CERTIFICATE_RECORD_STATUS_HISTORIES' AS string)                                           AS src_stm_code
    , CAST(ce_re_st_hi.created_at AS date)                                                                  AS data_dt
    , {{ generate_surrogate_key_bigint('NHNCK_CERTIFICATE_RECORDS', "ce_re_st_hi.certificate_record_id") }} AS sp_license_certificate_document_id
    , CAST(ce_re_st_hi.certificate_record_id AS string)                                                     AS sp_license_certificate_document_code
    , CAST(ce_re_st_hi.update_type AS string)                                                               AS update_tp
    , CAST(ce_re_st_hi.old_status AS string)                                                                AS old_certificate_status_code
    , CAST(ce_re_st_hi.new_status AS string)                                                                AS new_certificate_status_code
    , {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "ce_re_st_hi.decision_id") }}                     AS sp_license_decision_document_id
    , CAST(ce_re_st_hi.decision_id AS string)                                                               AS sp_license_decision_document_code
    , CAST(ce_re_st_hi.reason AS string)                                                                    AS change_reason
FROM ce_re_st_hi