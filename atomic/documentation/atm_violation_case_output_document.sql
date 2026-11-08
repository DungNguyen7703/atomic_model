/*
*--------------------------------------------------------------------*
* Program code: atm_violation_case_output_document
* Program name: Atomic Violation Case Output Document
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH vi_ca_ou_do AS (
    SELECT
        id
        , violation_case_id
        , document_type
        , document_number
        , document_name
        , document_date
        , penalty_decision_id
        , note
    FROM {{ ref('ods_thanhtra_violation_case_output_document') }}
),

vi_ca AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_violation_case') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_CASE_OUTPUT_DOCUMENT', "vi_ca_ou_do.id") }}      AS violation_case_output_document_id
    , CAST(vi_ca_ou_do.id AS string)                                                                      AS violation_case_output_document_code
    , CAST('THANHTRA_VIOLATION_CASE_OUTPUT_DOCUMENT' AS string)                                           AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_CASE', "vi_ca.code") }}                        AS violation_case_id
    , CAST(vi_ca_ou_do.violation_case_id AS string)                                                       AS violation_case_code
    , CAST(vi_ca_ou_do.document_type AS string)                                                           AS document_tp_code
    , CAST(vi_ca_ou_do.document_number AS string)                                                         AS document_nbr
    , CAST(vi_ca_ou_do.document_name AS string)                                                           AS document_nm
    , CAST(vi_ca_ou_do.document_date AS date)                                                             AS document_dt
    , {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION', "vi_ca_ou_do.penalty_decision_id") }} AS pd_id
    , CAST(vi_ca_ou_do.penalty_decision_id AS string)                                                     AS pd_code
    , CAST(vi_ca_ou_do.note AS string)                                                                    AS note
FROM vi_ca_ou_do
    LEFT JOIN vi_ca ON vi_ca_ou_do.VIOLATION_CASE_ID = vi_ca.ID