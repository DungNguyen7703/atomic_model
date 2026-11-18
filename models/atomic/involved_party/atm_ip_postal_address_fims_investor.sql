/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address FIMS.INVESTOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Bo sung province/ward theo LLD FIMS_INVESTOR_IP_Postal_Address.
* 2026-10-27		claude				Xoa cot province_nm/district_nm/ward_nm, sap lai thu tu cot theo template
*										scms_sc_firm_transaction_office.
*--------------------------------------------------------------------*
*/

WITH inve AS (
    SELECT
        transactioncode
        , address
        , provinceid
        , wardid
        , id
        , MAX(id) OVER (PARTITION BY transactioncode) AS max_id
    FROM {{ ref('ods_fims_investor') }}
),

inve_dedup AS (
    SELECT *
    FROM inve
    WHERE id = max_id
),

prov AS (
    SELECT
        id
        , code
        , namevn
    FROM {{ ref('ods_fims_province_new') }}
),

ward AS (
    SELECT
        id
        , code
        , namevn
    FROM {{ ref('ods_fims_ward_new') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_INVESTOR', "inve_dedup.transactioncode") }} AS ip_id
    , CAST(inve_dedup.transactioncode AS string)                                         AS ip_code
    , CAST('FIMS_INVESTOR' AS string)                                                    AS src_stm_code
    , CAST('HEAD_OFFICE' AS string)                                                      AS adr_tp_code
    , CAST(inve_dedup.address AS string)                                                 AS adr_val
    , CAST(NULL AS string)                                                               AS country_id
    , CAST(NULL AS string)                                                               AS country_code
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_NEW', "prov.code") }}              AS province_id
    , CAST(prov.code AS string)                                                          AS province_code
    , CAST(NULL AS string)                                                               AS district_id
    , CAST(NULL AS string)                                                               AS district_code
    , {{ generate_surrogate_key_bigint('ECAT_WARD_NEW', "ward.code") }}                  AS ward_id
    , CAST(ward.code AS string)                                                          AS ward_code
FROM inve_dedup
LEFT JOIN prov
    ON inve_dedup.provinceid = prov.id
LEFT JOIN ward
    ON inve_dedup.wardid = ward.id