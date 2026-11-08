/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address FMS.STF_FG_BRCH
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

WITH st_fg_br AS (
    SELECT
        id
        , address
    FROM {{ ref('ods_fms_stf_fg_brch') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_STF_FG_BRCH', "st_fg_br.id") }} AS ip_id
    , CAST(st_fg_br.id AS string)                                         AS ip_code
    , CAST('FMS_STF_FG_BRCH' AS string)                                   AS src_stm_code
    , CAST('ADDRESS' AS string)                                           AS adr_tp_code
    , CAST(st_fg_br.address AS string)                                    AS adr_val
    , CAST(NULL AS string)                                                AS country_id
    , CAST(NULL AS string)                                                AS country_code
    , CAST(NULL AS string)                                                AS province_id
    , CAST(NULL AS string)                                                AS province_code
    , CAST(NULL AS string)                                                AS district_id
    , CAST(NULL AS string)                                                AS district_code
    , CAST(NULL AS string)                                                AS ward_id
    , CAST(NULL AS string)                                                AS ward_code
FROM st_fg_br