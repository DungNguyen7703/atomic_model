/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address SCMS.BANK
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date		User		Description
*
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_BANK_IP_Postal_Address.yaml (khoi phuc tu 77a9749^)
*--------------------------------------------------------------------*
*/

WITH ba AS (
    SELECT
        id
        , address
    FROM {{ ref('ods_scms_bank') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_BANK', "ba.id") }} AS ip_id
    , CAST(ba.id AS string)                                     AS ip_code
    , CAST('SCMS_BANK' AS string)                               AS src_stm_code
    , CAST('HEAD_OFFICE' AS string)                             AS adr_tp_code
    , CAST(ba.address AS string)                                AS adr_val
    , CAST(NULL AS string)                                      AS country_id
    , CAST(NULL AS string)                                      AS country_code
    , CAST(NULL AS string)                                      AS province_id
    , CAST(NULL AS string)                                      AS province_code
    , CAST(NULL AS string)                                      AS district_id
    , CAST(NULL AS string)                                      AS district_code
    , CAST(NULL AS string)                                      AS ward_id
    , CAST(NULL AS string)                                      AS ward_code
FROM ba