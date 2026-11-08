/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address FMS.SECURITIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-07		claude				Bổ sung country/province/ward theo LLD SECURITIES_IP_Postal_Address: crosswalk COUNTRY_ID ->
*										ECAT.COUNTRY.ID, PROVINCE_ID/WARD_ID -> FMS.PROVINCE/WARD; hash theo CODE như các nhánh FMS khác
* 2026-10-12		claude				Dedupe prov/ward theo id (ROW_NUMBER, bản ghi mới nhất): ODS FMS.PROVINCE/WARD có 3 dòng/id
*										gây fan-out 3x3=9 => "[SCD4A] DUPLICATE KEY DETECTED" (etl_date=2026-10-07)
* 2026-10-27		claude				Xoa cot province_nm/district_nm/ward_nm, sap lai thu tu cot theo template
*										scms_sc_firm_transaction_office.
*--------------------------------------------------------------------*
*/

WITH secu AS (
    SELECT
        id
        , address
        , country_id
        , province_id
        , ward_id
    FROM {{ ref('ods_fms_securities') }}
),

coun AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_ecat_country') }}
),

prov AS (
    SELECT
        id
        , code
        , name_vn
    FROM (
        SELECT
            id
            , code
            , name_vn
            , ROW_NUMBER() OVER (
                PARTITION BY id
                ORDER BY date_modified DESC NULLS LAST, last_synced_at DESC NULLS LAST, code
            ) AS rn
        FROM {{ ref('ods_fms_province') }}
    ) t
    WHERE rn = 1
),

ward AS (
    SELECT
        id
        , code
        , name_vn
    FROM (
        SELECT
            id
            , code
            , name_vn
            , ROW_NUMBER() OVER (
                PARTITION BY id
                ORDER BY date_modified DESC NULLS LAST, last_synced_at DESC NULLS LAST, code
            ) AS rn
        FROM {{ ref('ods_fms_ward') }}
    ) t
    WHERE rn = 1
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_SECURITIES', "secu.id") }}        AS ip_id
    , CAST(secu.id AS string)                                               AS ip_code
    , CAST('FMS_SECURITIES' AS string)                                      AS src_stm_code
    , CAST('HEAD_OFFICE' AS string)                                         AS adr_tp_code
    , CAST(secu.address AS string)                                          AS adr_val
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "coun.code") }}      AS country_id
    , CAST(coun.code AS string)                                             AS country_code
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_NEW', "prov.code") }} AS province_id
    , CAST(prov.code AS string)                                             AS province_code
    , CAST(NULL AS string)                                                  AS district_id
    , CAST(NULL AS string)                                                  AS district_code
    , {{ generate_surrogate_key_bigint('ECAT_WARD_NEW', "ward.code") }}     AS ward_id
    , CAST(ward.code AS string)                                             AS ward_code
FROM secu
LEFT JOIN coun
    ON secu.country_id = coun.id
LEFT JOIN prov
    ON secu.province_id = prov.id
LEFT JOIN ward
    ON secu.ward_id = ward.id
