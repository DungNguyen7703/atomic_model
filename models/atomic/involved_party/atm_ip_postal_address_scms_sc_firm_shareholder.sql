/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address SCMS.SC_FIRM_SHAREHOLDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-27		claude				Xoa cot province_nm/district_nm/ward_nm, sap lai thu tu cot theo template
*										scms_sc_firm_transaction_office.
*--------------------------------------------------------------------*
*/

WITH sc_fi_sh AS (
    SELECT
        id
        , current_address
        , household_registration
    FROM {{ ref('ods_scms_sc_firm_shareholder') }}
),

unpvt AS (
    SELECT *
    FROM sc_fi_sh
    UNPIVOT (
        adr_val
        FOR adr_tp_code IN (
            current_address AS CURRENT,
            household_registration AS HOUSEHOLD_REGISTRY
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SHAREHOLDER', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                                  AS ip_code
    , CAST('SCMS_SC_FIRM_SHAREHOLDER' AS string)                                AS src_stm_code
    , CAST(unpvt.adr_tp_code AS string)                                         AS adr_tp_code
    , CAST(unpvt.adr_val AS string)                                             AS adr_val
    , CAST(NULL AS string)                                                      AS country_id
    , CAST(NULL AS string)                                                      AS country_code
    , CAST(NULL AS string)                                                      AS province_id
    , CAST(NULL AS string)                                                      AS province_code
    , CAST(NULL AS string)                                                      AS district_id
    , CAST(NULL AS string)                                                      AS district_code
    , CAST(NULL AS string)                                                      AS ward_id
    , CAST(NULL AS string)                                                      AS ward_code
FROM unpvt