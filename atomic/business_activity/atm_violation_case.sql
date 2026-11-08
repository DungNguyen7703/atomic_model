/*
*--------------------------------------------------------------------*
* Program code: atm_violation_case
* Program name: Atomic Violation Case
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH vi_ca AS (
    SELECT
        code
        , name
        , inspection_team_id
        , examination_team_id
        , source_category
        , status
        , market_type
        , bond_issuer_code
        , bond_code
    FROM {{ ref('ods_thanhtra_violation_case') }}
),

in_te AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_inspection_team') }}
),

ex_te AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_examination_team') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_CASE', "vi_ca.code") }}     AS violation_case_id
    , CAST(vi_ca.code AS string)                                                     AS violation_case_code
    , CAST('THANHTRA_VIOLATION_CASE' AS string)                                      AS src_stm_code
    , CAST(vi_ca.name AS string)                                                     AS violation_case_nm
    , {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_TEAM', "in_te.code") }}  AS inspection_team_id
    , CAST(in_te.code AS string)                                                     AS inspection_team_code
    , {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_TEAM', "ex_te.code") }} AS examination_team_id
    , CAST(ex_te.code AS string)                                                     AS examination_team_code
    , CAST(vi_ca.source_category AS string)                                          AS src_category_code
    , CAST(vi_ca.status AS string)                                                   AS life_cycle_status_code
    , CAST(vi_ca.market_type AS string)                                              AS market_tp_code
    , CAST(vi_ca.bond_issuer_code AS string)                                         AS bond_issuer_code
    , CAST(vi_ca.bond_code AS string)                                                AS bond_code
FROM vi_ca
    LEFT JOIN in_te ON vi_ca.INSPECTION_TEAM_ID = in_te.ID
    LEFT JOIN ex_te ON vi_ca.EXAMINATION_TEAM_ID = ex_te.ID