/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address FMS.DISTRIBUTOR_AGENT
* Created by: claude
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khởi tạo theo LLD DISTRIBUTOR_AGENT_IP_Postal_Address
* 2026-10-27		claude				Xoa cot province_nm/district_nm/ward_nm, sap lai thu tu cot theo template
*										scms_sc_firm_transaction_office.
*--------------------------------------------------------------------*
*/

WITH di_ag AS (
    SELECT
        id
        , address
    FROM {{ ref('ods_fms_distributor_agent') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_DISTRIBUTOR_AGENT', "di_ag.id") }} AS ip_id
    , CAST(di_ag.id AS string)                                               AS ip_code
    , CAST('FMS_DISTRIBUTOR_AGENT' AS string)                                AS src_stm_code
    , CAST('HEAD_OFFICE' AS string)                                          AS adr_tp_code
    , CAST(di_ag.address AS string)                                          AS adr_val
    , CAST(NULL AS string)                                                AS country_id
    , CAST(NULL AS string)                                                AS country_code
    , CAST(NULL AS string)                                                AS province_id
    , CAST(NULL AS string)                                                AS province_code
    , CAST(NULL AS string)                                                AS district_id
    , CAST(NULL AS string)                                                AS district_code
    , CAST(NULL AS string)                                                AS ward_id
    , CAST(NULL AS string)                                                AS ward_code
FROM di_ag
