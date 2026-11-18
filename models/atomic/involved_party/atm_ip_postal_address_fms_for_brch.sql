/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address FMS.FOR_BRCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-07		claude				Sắp lại thứ tự cột SELECT theo thứ tự chuẩn của atm_ip_postal_address (UNION ALL ghép theo vị trí)
* 2026-10-12		claude				Dedupe prov/ward theo id (ROW_NUMBER, bản ghi mới nhất): ODS FMS.PROVINCE/WARD có 3 dòng/id
*										gây fan-out 3x3=9 => "[SCD4A] DUPLICATE KEY DETECTED" (etl_date=2026-10-07)
* 2026-10-27		claude				Xoa cot province_nm/district_nm/ward_nm, sap lai thu tu cot theo template
*										scms_sc_firm_transaction_office.
*--------------------------------------------------------------------*
*/

WITH fo_br AS (
    SELECT
        id,
        province_id,
        ward_id,
        address,
        parent_address
    FROM {{ ref('ods_fms_for_brch') }}
),

prov AS (
    SELECT
        id,
        code,
        name_vn
    FROM (
        SELECT
            id,
            code,
            name_vn,
            ROW_NUMBER() OVER (
                PARTITION BY id
                ORDER BY date_modified DESC NULLS LAST, last_synced_at DESC NULLS LAST, code
            ) AS rn
        FROM {{ ref('ods_fms_province') }}
    ) t
    WHERE rn = 1
),

ward AS (
    SELECT
        id,
        code,
        name_vn
    FROM (
        SELECT
            id,
            code,
            name_vn,
            ROW_NUMBER() OVER (
                PARTITION BY id
                ORDER BY date_modified DESC NULLS LAST, last_synced_at DESC NULLS LAST, code
            ) AS rn
        FROM {{ ref('ods_fms_ward') }}
    ) t
    WHERE rn = 1
),

unpvt AS (
    SELECT *
    FROM fo_br
    UNPIVOT (
        adr_val
        FOR adr_tp_code IN (
            address AS FOREIGN_BRANCH,
            parent_address AS PARENT_ADDRESS
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_FOR_BRCH', "unpvt.id") }}       AS ip_id,
    CAST(unpvt.id AS string)                                              AS ip_code,
    CAST('FMS_FOR_BRCH' AS string)                                        AS src_stm_code,
    CAST(unpvt.adr_tp_code AS string)                                     AS adr_tp_code,
    CAST(unpvt.adr_val AS string)                                         AS adr_val,
    CAST(NULL AS string)                                                  AS country_id,
    CAST(NULL AS string)                                                  AS country_code,
    {{ generate_surrogate_key_bigint('ECAT_PROVINCE_NEW', "prov.code") }} AS province_id,
    CAST(prov.code AS string)                                             AS province_code,
    CAST(NULL AS string)                                                  AS district_id,
    CAST(NULL AS string)                                                  AS district_code,
    {{ generate_surrogate_key_bigint('ECAT_WARD_NEW', "ward.code") }}     AS ward_id,
    CAST(ward.code AS string)                                             AS ward_code
FROM unpvt
LEFT JOIN prov 
    ON unpvt.province_id = prov.id
LEFT JOIN ward 
    ON unpvt.ward_id = ward.id