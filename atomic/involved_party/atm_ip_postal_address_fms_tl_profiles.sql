/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address FMS.TL_PROFILES
* Created by: claude
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khởi tạo theo LLD TL_PROFILES_IP_Postal_Address
* 2026-10-27		claude				Xoa cot province_nm/district_nm/ward_nm, sap lai thu tu cot theo template
*										scms_sc_firm_transaction_office.
*--------------------------------------------------------------------*
*/

WITH tl_pr AS (
    SELECT
        id
        , address
        , current_add
        , add_work
    FROM {{ ref('ods_fms_tl_profiles') }}
),

unpvt AS (
    SELECT *
    FROM tl_pr
    UNPIVOT (
        adr_val
        FOR adr_tp_code IN (
            address AS ADDRESS,
            current_add AS CURRENT,
            add_work AS BUSINESS
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_TL_PROFILES', "unpvt.id") }}   AS ip_id
    , CAST(unpvt.id AS string)                                           AS ip_code
    , CAST('FMS_TL_PROFILES' AS string)                                  AS src_stm_code
    , CAST(unpvt.adr_tp_code AS string)                                  AS adr_tp_code
    , CAST(unpvt.adr_val AS string)                                      AS adr_val
    , CAST(NULL AS string)                                                AS country_id
    , CAST(NULL AS string)                                                AS country_code
    , CAST(NULL AS string)                                                AS province_id
    , CAST(NULL AS string)                                                AS province_code
    , CAST(NULL AS string)                                                AS district_id
    , CAST(NULL AS string)                                                AS district_code
    , CAST(NULL AS string)                                                AS ward_id
    , CAST(NULL AS string)                                                AS ward_code
FROM unpvt
