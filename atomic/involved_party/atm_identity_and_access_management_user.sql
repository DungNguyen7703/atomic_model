/*
*--------------------------------------------------------------------*
* Program code: atm_identity_and_access_management_user
* Program name: Atomic Identity And Access Management User
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao model theo lld_IAM_USERS.yaml (Fundamental -> scd4a). UAT chua co model IAM nao.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        full_name
        , username
        , date_of_birth
        , key_cloak_id
        , is_super_admin
        , user_type
        , organization_code
        , organization_name
        , gender
        , department_id
        , position_id
        , representative_name
        , representative_citizen_id
        , representative_phone
        , representative_email
        , code
        , practice_certificate_type_id
        , dial_number
        , stock_code
        , status_reason
        , member_id
        , member_name
        , ext_individual_member_id
        , ext_individual_member_name
        , securities_company_code
    FROM {{ ref('ods_iam_users') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IAM_USERS', "src.username") }} AS identity_and_access_management_user_id
    , CAST(src.username AS string)                                     AS identity_and_access_management_user_code
    , CAST('IAM_USERS' AS string)                                      AS src_stm_code
    , CAST(src.full_name AS string)                                    AS full_nm
    , CAST(src.code AS string)                                         AS user_code
    , CAST(src.date_of_birth AS date)                                  AS dt_of_birth
    , CAST(src.gender AS string)                                       AS individual_gender_code
    , CAST(src.user_type AS string)                                    AS ip_tp_code
    , CAST(src.is_super_admin AS int)                                  AS super_admin_ind
    , CAST(src.key_cloak_id AS string)                                 AS keycloak_id
    , CAST(src.organization_code AS string)                            AS organization_code
    , CAST(src.organization_name AS string)                            AS organization_nm
    , CAST(src.department_id AS string)                                AS department_id
    , CAST(src.position_id AS string)                                  AS position_id
    , CAST(src.stock_code AS string)                                   AS stock_code
    , CAST(src.practice_certificate_type_id AS string)                 AS practice_certificate_tp_id
    , CAST(src.status_reason AS string)                                AS status_reason
    , CAST(src.representative_name AS string)                          AS representative_nm
    , CAST(src.representative_citizen_id AS string)                    AS representative_citizen_id_nbr
    , CAST(src.representative_phone AS string)                         AS representative_phone
    , CAST(src.representative_email AS string)                         AS representative_email
    , CAST(src.dial_number AS string)                                  AS dial_nbr
    , CAST(src.member_id AS string)                                    AS member_id
    , CAST(src.member_name AS string)                                  AS member_nm
    , CAST(src.ext_individual_member_id AS string)                     AS external_individual_member_id
    , CAST(src.ext_individual_member_name AS string)                   AS external_individual_member_nm
    , CAST(src.securities_company_code AS string)                      AS sc_code
FROM src
