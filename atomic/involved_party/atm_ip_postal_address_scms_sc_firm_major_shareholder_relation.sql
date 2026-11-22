/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address SCMS.SC_FIRM_MAJOR_SHAREHOLDER_RELATION
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date		User		Description
*
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_MAJOR_SHAREHOLDER_RELATION_IP_Postal_Address.yaml (khoi phuc tu 77a9749^)
*--------------------------------------------------------------------*
*/

WITH sc_fi_ma_sh_re AS (
    SELECT
        id
        , address
    FROM {{ ref('ods_scms_sc_firm_major_shareholder_relation') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_MAJOR_SHAREHOLDER_RELATION', "sc_fi_ma_sh_re.id") }} AS ip_id
    , CAST(sc_fi_ma_sh_re.id AS string)                                                                   AS ip_code
    , CAST('SCMS_SC_FIRM_MAJOR_SHAREHOLDER_RELATION' AS string)                                           AS src_stm_code
    , CAST('CURRENT' AS string)                                                                           AS adr_tp_code
    , CAST(sc_fi_ma_sh_re.address AS string)                                                              AS adr_val
    , CAST(NULL AS string)                                                                                AS country_id
    , CAST(NULL AS string)                                                                                AS country_code
    , CAST(NULL AS string)                                                                                AS province_id
    , CAST(NULL AS string)                                                                                AS province_code
    , CAST(NULL AS string)                                                                                AS district_id
    , CAST(NULL AS string)                                                                                AS district_code
    , CAST(NULL AS string)                                                                                AS ward_id
    , CAST(NULL AS string)                                                                                AS ward_code
FROM sc_fi_ma_sh_re