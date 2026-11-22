/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address_fms_transfer_agent
* Program name: Atomic IP Postal Address FMS.TRANSFER_AGENT
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh FMS theo lld_FMS_TRANSFER_AGENT_IP_Postal_Address.yaml (UAT chua co).
*--------------------------------------------------------------------*
*/

WITH ta AS (
    SELECT
        id
        , address
    FROM {{ ref('ods_fms_transfer_agent') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_TRANSFER_AGENT', "ta.id") }} AS ip_id
    , CAST(ta.id AS string)                                              AS ip_code
    , CAST('FMS_TRANSFER_AGENT' AS string)                               AS src_stm_code
    , CAST('HEAD_OFFICE' AS string)                                      AS adr_tp_code
    , CAST(ta.address AS string)                                         AS adr_val
    , CAST(NULL AS string)                                               AS country_id
    , CAST(NULL AS string)                                               AS country_code
    , CAST(NULL AS string)                                               AS province_id
    , CAST(NULL AS string)                                               AS province_code
    , CAST(NULL AS string)                                               AS district_id
    , CAST(NULL AS string)                                               AS district_code
    , CAST(NULL AS string)                                               AS ward_id
    , CAST(NULL AS string)                                               AS ward_code
FROM ta
