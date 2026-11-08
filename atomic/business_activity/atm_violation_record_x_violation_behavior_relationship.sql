/*
*--------------------------------------------------------------------*
* Program code: atm_violation_record_x_violation_behavior_relationship
* Program name: Atomic Violation Record Behavior
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-25		tuan.nguyenvanb		[LLD atomic lld_THANHTRA_VIOLATION_RECORD_BEHAVIOR.yaml] xoa description, legal_basis; giu violation_record_behavior_id/code (quyet dinh user, se raise design)
* 2026-10-25		tuan.nguyenvanb		[DESIGN tra loi] Bo violation_record_behavior_id/code (khop LLD, 5 cot). Mart tu ghep khoa CONCAT(violation_record_code, '_', violation_behavior_code). unique_key doi sang (violation_record_id, violation_behavior_id).
*--------------------------------------------------------------------*
*/

WITH vi_re_be AS (
    SELECT
        violation_record_id
        , violation_behavior_id
    FROM {{ ref('ods_thanhtra_violation_record_behavior') }}
),

vi_be AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_violation_behavior') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_RECORD', "vi_re_be.violation_record_id") }} AS violation_record_id
    , CAST(vi_re_be.violation_record_id AS string)                                                     AS violation_record_code
    , {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_BEHAVIOR', "vi_be.code") }}                 AS violation_behavior_id
    , CAST(vi_be.code AS string)                                                                       AS violation_behavior_code
    , CAST('THANHTRA_VIOLATION_RECORD_BEHAVIOR' AS string)                                             AS src_stm_code
FROM vi_re_be
    LEFT JOIN vi_be ON vi_re_be.VIOLATION_BEHAVIOR_ID = vi_be.ID