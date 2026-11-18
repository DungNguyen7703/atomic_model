/*
*--------------------------------------------------------------------*
* Program code: atm_violation_case_received_document
* Program name: Atomic Violation Case Received Document
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH vi_ca_re_do AS (
    SELECT
        id
        , violation_case_id
        , document_number
        , document_date
        , issuing_unit_name
        , violation_subject_name
        , violation_record_id
    FROM {{ ref('ods_thanhtra_violation_case_received_document') }}
),

vi_ca AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_violation_case') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_CASE_RECEIVED_DOCUMENT', "vi_ca_re_do.id") }}    AS violation_case_received_document_id
    , CAST(vi_ca_re_do.id AS string)                                                                      AS violation_case_received_document_code
    , CAST('THANHTRA_VIOLATION_CASE_RECEIVED_DOCUMENT' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_CASE', "vi_ca.code") }}                        AS violation_case_id
    , CAST(vi_ca_re_do.violation_case_id AS string)                                                       AS violation_case_code
    , CAST(vi_ca_re_do.document_number AS string)                                                         AS document_nbr
    , CAST(vi_ca_re_do.document_date AS date)                                                             AS document_dt
    , CAST(vi_ca_re_do.issuing_unit_name AS string)                                                       AS issuing_unit_nm
    , CAST(vi_ca_re_do.violation_subject_name AS string)                                                  AS violation_subject_nm
    , {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_RECORD', "vi_ca_re_do.violation_record_id") }} AS violation_record_id
    , CAST(vi_ca_re_do.violation_record_id AS string)                                                     AS violation_record_code
FROM vi_ca_re_do
    LEFT JOIN vi_ca ON vi_ca_re_do.VIOLATION_CASE_ID = vi_ca.ID