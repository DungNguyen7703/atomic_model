/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification IAM.USERS
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao nhanh shared entity theo lld_IAM_USERS_IP_Alt_Identification.yaml (UAT chua co). ip_id = hash IAM_USERS tu USERNAME (khop atm_identity_and_access_management_user).
*--------------------------------------------------------------------*
*/

WITH us AS (
    SELECT
        username
        , citizen_id_number
        , tax_id_number
    FROM {{ ref('ods_iam_users') }}
    WHERE username IS NOT NULL
),

unpvt AS (
    SELECT *
    FROM us
    UNPIVOT (
        identification_nbr
        FOR identification_tp_code IN (
            citizen_id_number AS CITIZEN_ID,
            tax_id_number AS TAX_ID
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('IAM_USERS', "unpvt.username") }} AS ip_id
    , CAST(unpvt.username AS string)                                    AS ip_code
    , CAST('IAM_USERS' AS string)                                       AS src_stm_code
    , CAST(unpvt.identification_tp_code AS string)                      AS identification_tp_code
    , CAST(unpvt.identification_nbr AS string)                          AS identification_nbr
    , CAST(NULL AS date)                                                AS identification_issue_dt
    , CAST(NULL AS string)                                              AS identification_issue_place
FROM unpvt
