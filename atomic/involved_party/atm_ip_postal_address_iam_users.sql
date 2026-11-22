/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address IAM.USERS
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao nhanh shared entity theo lld_IAM_USERS_IP_Postal_Address.yaml (UAT chua co). ip_id = hash IAM_USERS tu USERNAME (khop atm_identity_and_access_management_user).
*--------------------------------------------------------------------*
*/

WITH us AS (
    SELECT
        username
        , address
    FROM {{ ref('ods_iam_users') }}
    WHERE username IS NOT NULL
)

SELECT
    {{ generate_surrogate_key_bigint('IAM_USERS', "us.username") }} AS ip_id
    , CAST(us.username AS string)                                    AS ip_code
    , CAST('IAM_USERS' AS string)                                    AS src_stm_code
    , CAST('PERMANENT' AS string)                                    AS adr_tp_code
    , CAST(us.address AS string)                                     AS adr_val
    , CAST(NULL AS string)                                           AS country_id
    , CAST(NULL AS string)                                           AS country_code
    , CAST(NULL AS string)                                           AS province_id
    , CAST(NULL AS string)                                           AS province_code
    , CAST(NULL AS string)                                           AS district_id
    , CAST(NULL AS string)                                           AS district_code
    , CAST(NULL AS string)                                           AS ward_id
    , CAST(NULL AS string)                                           AS ward_code
FROM us
