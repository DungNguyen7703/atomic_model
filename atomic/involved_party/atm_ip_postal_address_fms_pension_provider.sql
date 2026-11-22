/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address_fms_pension_provider
* Program name: Atomic IP Postal Address FMS.PENSION_PROVIDER
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh FMS theo lld_FMS_PENSION_PROVIDER_IP_Postal_Address.yaml (UAT chua co).
*--------------------------------------------------------------------*
*/

WITH pp AS (
    SELECT
        id
        , address
    FROM {{ ref('ods_fms_pension_provider') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_PENSION_PROVIDER', "pp.id") }} AS ip_id
    , CAST(pp.id AS string)                                                AS ip_code
    , CAST('FMS_PENSION_PROVIDER' AS string)                               AS src_stm_code
    , CAST('HEAD_OFFICE' AS string)                                        AS adr_tp_code
    , CAST(pp.address AS string)                                           AS adr_val
    , CAST(NULL AS string)                                                 AS country_id
    , CAST(NULL AS string)                                                 AS country_code
    , CAST(NULL AS string)                                                 AS province_id
    , CAST(NULL AS string)                                                 AS province_code
    , CAST(NULL AS string)                                                 AS district_id
    , CAST(NULL AS string)                                                 AS district_code
    , CAST(NULL AS string)                                                 AS ward_id
    , CAST(NULL AS string)                                                 AS ward_code
FROM pp
