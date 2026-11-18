/*
*--------------------------------------------------------------------*
* Program code: atm_violation_behavior_x_penalty_type_relationship
* Program name: Atomic Violation Behavior X Penalty Type Relationship
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao model theo LLD THANHTRA_PENALTY_TYPE_VIOLATION_BEHAVIOR.
*--------------------------------------------------------------------*
*/

WITH pe_ty_vi_be AS (
    SELECT
        penalty_type_id
        , violation_behavior_id
    FROM {{ ref('ods_thanhtra_penalty_type_violation_behavior') }}
),

pt AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_penalty_type') }}
),

vi_be AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_violation_behavior') }}
)

SELECT
    CAST('THANHTRA_PENALTY_TYPE_VIOLATION_BEHAVIOR' AS string)                       AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_BEHAVIOR', "vi_be.code") }} AS violation_behavior_id
    , CAST(vi_be.code AS string)                                                       AS violation_behavior_code
    , {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_TYPE', "pt.code") }}          AS cl_thanhtra_penalty_tp_id
    , CAST(pt.code AS string)                                                          AS cl_thanhtra_penalty_tp_code
FROM pe_ty_vi_be
    LEFT JOIN pt ON pe_ty_vi_be.penalty_type_id = pt.id
    LEFT JOIN vi_be ON pe_ty_vi_be.violation_behavior_id = vi_be.id