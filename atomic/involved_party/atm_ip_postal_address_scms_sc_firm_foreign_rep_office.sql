/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address SCMS.SC_FIRM_FOREIGN_REP_OFFICE
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date		User		Description
*
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_FOREIGN_REP_OFFICE_IP_Postal_Address.yaml (khoi phuc tu 77a9749^)
*--------------------------------------------------------------------*
*/

WITH sc_fi_fo_re_of AS (
    SELECT
        id
        , address
    FROM {{ ref('ods_scms_sc_firm_foreign_rep_office') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_REP_OFFICE', "sc_fi_fo_re_of.id") }} AS ip_id
    , CAST(sc_fi_fo_re_of.id AS string)                                                           AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_REP_OFFICE' AS string)                                           AS src_stm_code
    , CAST('FOREIGN_REP_OFFICE' AS string)                                                        AS adr_tp_code
    , CAST(sc_fi_fo_re_of.address AS string)                                                      AS adr_val
    , CAST(NULL AS string)                                                                        AS country_id
    , CAST(NULL AS string)                                                                        AS country_code
    , CAST(NULL AS string)                                                                        AS province_id
    , CAST(NULL AS string)                                                                        AS province_code
    , CAST(NULL AS string)                                                                        AS district_id
    , CAST(NULL AS string)                                                                        AS district_code
    , CAST(NULL AS string)                                                                        AS ward_id
    , CAST(NULL AS string)                                                                        AS ward_code
FROM sc_fi_fo_re_of