/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address IDS.COMPANY_PROFILES
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

WITH co_pr AS (
    SELECT
        id
        , province_id
        , latest_reg_prov
        , head_office_addr
        , trading_office_addr
    FROM {{ ref('ods_ids_company_profiles') }}
),

unpvt AS (
    SELECT *
    FROM co_pr
    UNPIVOT (
        adr_val
        FOR adr_tp_code IN (
            head_office_addr AS HEAD_OFFICE,
            trading_office_addr AS TRANSACTION_OFFICE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "unpvt.id") }}            AS ip_id
    , CAST(unpvt.id AS string)                                                         AS ip_code
    , CAST('IDS_COMPANY_PROFILES' AS string)                                           AS src_stm_code
    , CAST(unpvt.adr_tp_code AS string)                                                AS adr_tp_code
    , CAST(unpvt.adr_val AS string)                                                    AS adr_val
    , CAST(NULL AS string)                                                             AS country_id
    , CAST(NULL AS string)                                                             AS country_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "unpvt.province_id") }} AS province_id
    , CAST(unpvt.latest_reg_prov AS string)                                            AS province_code
    , CAST(NULL AS string)                                                             AS district_id
    , CAST(NULL AS string)                                                             AS district_code
    , CAST(NULL AS string)                                                             AS ward_id
    , CAST(NULL AS string)                                                             AS ward_code
FROM unpvt