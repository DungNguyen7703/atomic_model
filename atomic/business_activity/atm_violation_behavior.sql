/*
*--------------------------------------------------------------------*
* Program code: atm_violation_behavior
* Program name: Atomic Violation Behavior
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH vi_be AS (
    SELECT
        code
        , name
        , description
        , primary_penalty_type_id
        , min_fine_amount
        , max_fine_amount
        , remedial_measure
        , status
        , note
        , legal_document
        , violation_clause
    FROM {{ ref('ods_thanhtra_violation_behavior') }}
),

pe_ty AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_penalty_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_BEHAVIOR', "vi_be.code") }} AS violation_behavior_id
    , CAST(vi_be.code AS string)                                                     AS violation_behavior_code
    , CAST('THANHTRA_VIOLATION_BEHAVIOR' AS string)                                  AS src_stm_code
    , CAST(vi_be.name AS string)                                                     AS violation_behavior_nm
    , CAST(vi_be.description AS string)                                              AS description
    , {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_TYPE', "pe_ty.code") }}     AS cl_thanhtra_penalty_tp_id
    , CAST(pe_ty.code AS string)                                                     AS cl_thanhtra_penalty_tp_code
    , CAST(vi_be.min_fine_amount AS decimal(23,2))                                   AS min_fine_amt
    , CAST(vi_be.max_fine_amount AS decimal(23,2))                                   AS max_fine_amt
    , CAST(vi_be.remedial_measure AS string)                                         AS remedial_measure
    , CAST(vi_be.status AS string)                                                   AS life_cycle_status_code
    , CAST(vi_be.note AS string)                                                     AS note
    , CAST(vi_be.legal_document AS string)                                           AS legal_document
    , CAST(vi_be.violation_clause AS string)                                         AS violation_clause
FROM vi_be
    LEFT JOIN pe_ty ON vi_be.PRIMARY_PENALTY_TYPE_ID = pe_ty.ID