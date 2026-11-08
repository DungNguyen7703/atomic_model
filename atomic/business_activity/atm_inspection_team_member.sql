/*
*--------------------------------------------------------------------*
* Program code: atm_inspection_team_member
* Program name: Atomic Inspection Team Member
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH in_te_me AS (
    SELECT
        id
        , inspection_team_id
        , user_id
        , user_account
        , user_full_name
        , department_name
        , role_in_team
    FROM {{ ref('ods_thanhtra_inspection_team_member') }}
),

in_te AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_inspection_team') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_TEAM_MEMBER', "in_te_me.id") }} AS inspection_team_member_id
    , CAST(in_te_me.id AS string)                                                         AS inspection_team_member_code
    , CAST('THANHTRA_INSPECTION_TEAM_MEMBER' AS string)                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_TEAM', "in_te.code") }}       AS inspection_team_id
    , CAST(in_te_me.inspection_team_id AS string)                                         AS inspection_team_code
    , {{ generate_surrogate_key_bigint('IAM_USERS', "in_te_me.user_id") }}                AS member_officer_id
    , CAST(in_te_me.user_account AS string)                                               AS member_officer_code
    , CAST(in_te_me.user_full_name AS string)                                             AS member_full_nm
    , CAST(in_te_me.department_name AS string)                                            AS member_department_nm
    , CAST(in_te_me.role_in_team AS string)                                               AS role_in_team_code
FROM in_te_me
    LEFT JOIN in_te ON in_te_me.INSPECTION_TEAM_ID = in_te.ID