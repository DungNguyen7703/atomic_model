/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address IAM.USERS
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao nhanh shared entity theo lld_IAM_USERS_IP_Electronic_Address.yaml (UAT chua co). ip_id = hash IAM_USERS tu USERNAME (khop atm_identity_and_access_management_user).
*--------------------------------------------------------------------*
*/

WITH us AS (
    SELECT
        username
        , email
        , phone
        , office_phone
    FROM {{ ref('ods_iam_users') }}
    WHERE username IS NOT NULL
),

unpvt AS (
    SELECT *
    FROM us
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            email AS EMAIL,
            phone AS MOBILE,
            office_phone AS PHONE_OFFICE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('IAM_USERS', "unpvt.username") }} AS ip_id
    , CAST(unpvt.username AS string)                                    AS ip_code
    , CAST('IAM_USERS' AS string)                                       AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                      AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                          AS electronic_adr_val
FROM unpvt
