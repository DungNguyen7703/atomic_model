/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address_fims_bankmoni
* Program name: Atomic Involved Party Postal Address FIMS.BANKMONI
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao model theo LLD FIMS_BANKMONI_IP_Postal_Address.
* 2026-10-27		claude				Xoa cot province_nm/district_nm/ward_nm, sap lai thu tu cot theo template
*										scms_sc_firm_transaction_office.
*--------------------------------------------------------------------*
*/

WITH ba_mo AS (
    SELECT
        id
        , address
    FROM {{ ref('ods_fims_bankmoni') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_BANKMONI', "ba_mo.id") }} AS ip_id
    , CAST(ba_mo.id AS string)                                         AS ip_code
    , CAST('FIMS_BANKMONI' AS string)                                  AS src_stm_code
    , CAST('HEAD_OFFICE' AS string)                                    AS adr_tp_code
    , CAST(ba_mo.address AS string)                                    AS adr_val
    , CAST(NULL AS string)                                             AS country_id
    , CAST(NULL AS string)                                             AS country_code
    , CAST(NULL AS string)                                             AS province_id
    , CAST(NULL AS string)                                             AS province_code
    , CAST(NULL AS string)                                             AS district_id
    , CAST(NULL AS string)                                             AS district_code
    , CAST(NULL AS string)                                             AS ward_id
    , CAST(NULL AS string)                                             AS ward_code
FROM ba_mo