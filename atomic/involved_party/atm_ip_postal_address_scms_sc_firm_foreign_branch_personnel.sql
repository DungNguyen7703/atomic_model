/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address SCMS.SC_FIRM_FOREIGN_BRANCH_PERSONNEL
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date		User		Description
*
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL_IP_Postal_Address.yaml (khoi phuc tu 77a9749^)
*--------------------------------------------------------------------*
*/

WITH sc_fi_fo_br_pe AS (
    SELECT
        id
        , address
        , permanent_address
    FROM {{ ref('ods_scms_sc_firm_foreign_branch_personnel') }}
),

unpvt AS (
    SELECT *
    FROM sc_fi_fo_br_pe
    UNPIVOT (
        adr_val
        FOR adr_tp_code IN (
            address AS CURRENT,
            permanent_address AS PERMANENT
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                                                 AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL' AS string)                                  AS src_stm_code
    , CAST(unpvt.adr_tp_code AS string)                                                        AS adr_tp_code
    , CAST(unpvt.adr_val AS string)                                                            AS adr_val
    , CAST(NULL AS string)                                                                     AS country_id
    , CAST(NULL AS string)                                                                     AS country_code
    , CAST(NULL AS string)                                                                     AS province_id
    , CAST(NULL AS string)                                                                     AS province_code
    , CAST(NULL AS string)                                                                     AS district_id
    , CAST(NULL AS string)                                                                     AS district_code
    , CAST(NULL AS string)                                                                     AS ward_id
    , CAST(NULL AS string)                                                                     AS ward_code
FROM unpvt