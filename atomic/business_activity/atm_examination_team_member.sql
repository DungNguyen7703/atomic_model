/*
*--------------------------------------------------------------------*
* Program code: atm_examination_team_member
* Program name: Atomic Examination Team Member
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ex_te_me AS (
    SELECT
        id
        , examination_team_id
        , user_id
        , user_account
        , user_full_name
        , department_name
        , role_in_team
    FROM {{ ref('ods_thanhtra_examination_team_member') }}
),

ex_te AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_examination_team') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_TEAM_MEMBER', "ex_te_me.id") }} AS examination_team_member_id
    , CAST(ex_te_me.id AS string)                                                          AS examination_team_member_code
    , CAST('THANHTRA_EXAMINATION_TEAM_MEMBER' AS string)                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_TEAM', "ex_te.code") }}       AS examination_team_id
    , CAST(ex_te_me.examination_team_id AS string)                                         AS examination_team_code
    , {{ generate_surrogate_key_bigint('IAM_USERS', "ex_te_me.user_id") }}                 AS member_officer_id
    , CAST(ex_te_me.user_account AS string)                                                AS member_officer_code
    , CAST(ex_te_me.user_full_name AS string)                                              AS member_full_nm
    , CAST(ex_te_me.department_name AS string)                                             AS member_department_nm
    , CAST(ex_te_me.role_in_team AS string)                                                AS role_in_team_code
FROM ex_te_me
    LEFT JOIN ex_te ON ex_te_me.EXAMINATION_TEAM_ID = ex_te.ID