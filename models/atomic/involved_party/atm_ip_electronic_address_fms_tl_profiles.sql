/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address FMS.TL_PROFILES
* Created by: claude
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khởi tạo theo LLD TL_PROFILES_IP_Electronic_Address
*--------------------------------------------------------------------*
*/

WITH tl_pr AS (
    SELECT
        id
        , telephone
        , cell_phone
        , fax
        , email
        , pl_email
    FROM {{ ref('ods_fms_tl_profiles') }}
),

unpvt AS (
    SELECT *
    FROM tl_pr
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            telephone AS PHONE,
            cell_phone AS MOBILE,
            fax AS FAX,
            email AS EMAIL,
            pl_email AS EMAIL_PERSONAL
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_TL_PROFILES', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                         AS ip_code
    , CAST('FMS_TL_PROFILES' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                     AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                         AS electronic_adr_val
FROM unpvt
