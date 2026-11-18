/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address FMS.BANK_MONI
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-07		claude				Sắp lại thứ tự cột SELECT theo thứ tự chuẩn của atm_ip_postal_address (UNION ALL ghép theo vị trí)
* 2026-10-27		claude				Xoa cot province_nm/district_nm/ward_nm, sap lai thu tu cot theo template
*										scms_sc_firm_transaction_office.
*--------------------------------------------------------------------*
*/

WITH ba_mo AS (
    SELECT
        id
        , address
        , province_id
        , ward_id
    FROM {{ ref('ods_fms_bank_moni') }}
),

prov AS (
    SELECT
        id
        , code
        , name_vn
    FROM {{ ref('ods_fms_province') }}
),

ward AS (
    SELECT
        id
        , code
        , name_vn
    FROM {{ ref('ods_fms_ward') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "ba_mo.id") }}        AS ip_id
    , CAST(ba_mo.id AS string)                                              AS ip_code
    , CAST('FMS_BANK_MONI' AS string)                                       AS src_stm_code
    , CAST('HEAD_OFFICE' AS string)                                         AS adr_tp_code
    , CAST(ba_mo.address AS string)                                         AS adr_val
    , CAST(NULL AS string)                                                  AS country_id
    , CAST(NULL AS string)                                                  AS country_code
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_NEW', "prov.code") }} AS province_id
    , CAST(prov.code AS string)                                             AS province_code
    , CAST(NULL AS string)                                                  AS district_id
    , CAST(NULL AS string)                                                  AS district_code
    , {{ generate_surrogate_key_bigint('ECAT_WARD_NEW', "ward.code") }}     AS ward_id
    , CAST(ward.code AS string)                                             AS ward_code
FROM ba_mo
LEFT JOIN prov 
    ON ba_mo.province_id = prov.id
LEFT JOIN ward 
    ON ba_mo.ward_id = ward.id