/*
*--------------------------------------------------------------------*
* Program code: atm_penalty_type
* Program name: Atomic Penalty Type
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pe_ty AS (
    SELECT
        code
        , name
        , category
        , description
        , status
        , legal_basis
        , note
    FROM {{ ref('ods_thanhtra_penalty_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_TYPE', "pe_ty.code") }} AS penalty_tp_id
    , CAST(pe_ty.code AS string)                                               AS penalty_tp_code
    , CAST('THANHTRA_PENALTY_TYPE' AS string)                                  AS src_stm_code
    , CAST(pe_ty.name AS string)                                               AS penalty_tp_nm
    , CAST(pe_ty.category AS string)                                           AS penalty_category_code
    , CAST(pe_ty.description AS string)                                        AS description
    , CAST(pe_ty.status AS string)                                             AS life_cycle_status_code
    , CAST(pe_ty.legal_basis AS string)                                        AS legal_basis
    , CAST(pe_ty.note AS string)                                               AS note
FROM pe_ty