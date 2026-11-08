/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address NHNCK.PROFESSIONALS
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

WITH pro AS (
    SELECT
        id
        , current_country_id
        , current_province_id
        , current_district_id
        , permanent_country_id
        , permanent_province_id
        , permanent_district_id
    FROM {{ ref('ods_nhnck_professionals') }}
),

unpvt AS (
    SELECT *
    FROM pro
    UNPIVOT (
        (country_id, country_code, province_id, province_code, district_id, district_code)
        FOR adr_tp_code IN (
            (current_country_id, current_country_id, current_province_id, current_province_id, current_district_id, current_district_id) AS CURRENT,
            (permanent_country_id, permanent_country_id, permanent_province_id, permanent_province_id, permanent_district_id, permanent_district_id) AS PERMANENT
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                             AS ip_code
    , CAST('NHNCK_PROFESSIONALS' AS string)                                AS src_stm_code
    , CAST(unpvt.adr_tp_code AS string)                                    AS adr_tp_code
    , CAST(null AS string)                                                 AS adr_val
    , CAST(unpvt.country_id AS string)                                     AS country_id
    , CAST(unpvt.country_code AS string)                                   AS country_code
    , CAST(unpvt.province_id AS string)                                    AS province_id
    , CAST(unpvt.province_code AS string)                                  AS province_code
    , CAST(unpvt.district_id AS string)                                    AS district_id
    , CAST(unpvt.district_code AS string)                                  AS district_code
    , CAST(NULL AS string)                                                 AS ward_id
    , CAST(NULL AS string)                                                 AS ward_code
FROM unpvt