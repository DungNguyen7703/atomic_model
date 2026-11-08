/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address NHNCK.UNITS
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

WITH unit AS (
    SELECT
        id
        , unit_code
        , address
    FROM {{ ref('ods_nhnck_units') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_UNITS', "unit.id") }} AS ip_id
    , CAST(unit.unit_code AS string)                              AS ip_code
    , CAST('NHNCK_UNITS' AS string)                               AS src_stm_code
    , CAST('HEAD_OFFICE' AS string)                               AS adr_tp_code
    , CAST(unit.address AS string)                                AS adr_val
    , CAST(NULL AS string)                                        AS country_id
    , CAST(NULL AS string)                                        AS country_code
    , CAST(NULL AS string)                                        AS province_id
    , CAST(NULL AS string)                                        AS province_code
    , CAST(NULL AS string)                                        AS district_id
    , CAST(NULL AS string)                                        AS district_code
    , CAST(NULL AS string)                                        AS ward_id
    , CAST(NULL AS string)                                        AS ward_code
FROM unit