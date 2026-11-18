/*
*--------------------------------------------------------------------*
* Program code: atm_penalty_decision_x_violation_record_relationship
* Program name: Atomic Penalty Decision X Violation Record
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date        User        Description
*
*--------------------------------------------------------------------*
*/

WITH pe_de_vi_re AS (
    SELECT
        penalty_decision_id
        , violation_record_id
    FROM {{ ref('ods_thanhtra_penalty_decision_violation_record') }}
),

pe_de AS (
    SELECT
        id
    FROM {{ ref('ods_thanhtra_penalty_decision') }}
),

vi_re AS (
    SELECT
        id
    FROM {{ ref('ods_thanhtra_violation_record') }}
)

SELECT
    CAST('THANHTRA_PENALTY_DECISION_VIOLATION_RECORD' AS string)                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION', "pe_de_vi_re.penalty_decision_id") }} AS pd_id
    , CAST(pe_de.id AS string)                                                                            AS pd_code
    , {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_RECORD', "pe_de_vi_re.violation_record_id") }} AS violation_record_id
    , CAST(vi_re.id AS string)                                                                            AS violation_record_code
FROM pe_de_vi_re
    LEFT JOIN pe_de ON pe_de_vi_re.penalty_decision_id = pe_de.Id
    LEFT JOIN vi_re ON pe_de_vi_re.violation_record_id = vi_re.Id