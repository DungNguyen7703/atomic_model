/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address FMS.INSIDER
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

WITH insi AS (
    SELECT
        id
        , address
    FROM {{ ref('ods_fms_insider') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_INSIDER', "insi.id") }} AS ip_id
    , CAST(insi.id AS string)                                     AS ip_code
    , CAST('FMS_INSIDER' AS string)                               AS src_stm_code
    , CAST('ADDRESS' AS string)                                   AS adr_tp_code
    , CAST(insi.address AS string)                                AS adr_val
    , CAST(NULL AS string)                                        AS country_id
    , CAST(NULL AS string)                                        AS country_code
    , CAST(NULL AS string)                                        AS province_id
    , CAST(NULL AS string)                                        AS province_code
    , CAST(NULL AS string)                                        AS district_id
    , CAST(NULL AS string)                                        AS district_code
    , CAST(NULL AS string)                                        AS ward_id
    , CAST(NULL AS string)                                        AS ward_code
FROM insi