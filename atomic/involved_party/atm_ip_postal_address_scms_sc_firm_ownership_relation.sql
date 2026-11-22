/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address SCMS.SC_FIRM_OWNERSHIP_RELATION
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date		User		Description
*
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_OWNERSHIP_RELATION_IP_Postal_Address.yaml (viet moi)
*--------------------------------------------------------------------*
*/

WITH sc_fi_ow_re AS (
    SELECT
        id
        , registered_address
    FROM {{ ref('ods_scms_sc_firm_ownership_relation') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_OWNERSHIP_RELATION', "sc_fi_ow_re.id") }} AS ip_id
    , CAST(sc_fi_ow_re.id AS string)                                                           AS ip_code
    , CAST('SCMS_SC_FIRM_OWNERSHIP_RELATION' AS string)                                        AS src_stm_code
    , CAST('ADDRESS' AS string)                                                                AS adr_tp_code
    , CAST(sc_fi_ow_re.registered_address AS string)                                           AS adr_val
    , CAST(NULL AS string)                                                                     AS country_id
    , CAST(NULL AS string)                                                                     AS country_code
    , CAST(NULL AS string)                                                                     AS province_id
    , CAST(NULL AS string)                                                                     AS province_code
    , CAST(NULL AS string)                                                                     AS district_id
    , CAST(NULL AS string)                                                                     AS district_code
    , CAST(NULL AS string)                                                                     AS ward_id
    , CAST(NULL AS string)                                                                     AS ward_code
FROM sc_fi_ow_re