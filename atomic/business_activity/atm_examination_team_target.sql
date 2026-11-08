/*
*--------------------------------------------------------------------*
* Program code: atm_examination_team_target
* Program name: Atomic Examination Team Target
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ex_te_ta AS (
    SELECT
        id
        , examination_team_id
        , target_type
        , target_reference_id
        , target_name
        , address
        , account_number
        , securities_company_name
        , citizen_id
        , business_registration_number
        , legal_rep_name
        , legal_rep_citizen_id
        , start_date
        , end_date
    FROM {{ ref('ods_thanhtra_examination_team_target') }}
),

ex_te AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_examination_team') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_TEAM_TARGET', "ex_te_ta.id") }} AS examination_team_target_id
    , CAST(ex_te_ta.id AS string)                                                          AS examination_team_target_code
    , CAST('THANHTRA_EXAMINATION_TEAM_TARGET' AS string)                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_TEAM', "ex_te.code") }}       AS examination_team_id
    , CAST(ex_te.code AS string)                                                           AS examination_team_code
    , CAST(ex_te_ta.target_type AS string)                                                 AS target_tp_code
    , CAST(ex_te_ta.target_reference_id AS string)                                         AS target_reference_id
    , CAST(ex_te_ta.target_name AS string)                                                 AS target_nm
    , CAST(ex_te_ta.address AS string)                                                     AS target_adr
    , CAST(ex_te_ta.account_number AS string)                                              AS account_nbr
    , CAST(ex_te_ta.securities_company_name AS string)                                     AS sc_nm
    , CAST(ex_te_ta.citizen_id AS string)                                                  AS citizen_id
    , CAST(ex_te_ta.business_registration_number AS string)                                AS business_registration_nbr
    , CAST(ex_te_ta.legal_rep_name AS string)                                              AS legal_rep_nm
    , CAST(ex_te_ta.legal_rep_citizen_id AS string)                                        AS legal_rep_citizen_id
    , CAST(ex_te_ta.start_date AS date)                                                    AS start_dt
    , CAST(ex_te_ta.end_date AS date)                                                      AS end_dt
FROM ex_te_ta
    LEFT JOIN ex_te ON ex_te_ta.EXAMINATION_TEAM_ID = ex_te.ID