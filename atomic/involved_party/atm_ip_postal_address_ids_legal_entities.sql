/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address IDS.LEGAL_ENTITIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH le AS (
    SELECT
        id
        , address
    FROM {{ ref('ods_ids_legal_entities') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "id") }} AS ip_id
    , CAST(id AS string)                                            AS ip_code
    , CAST('IDS_LEGAL_ENTITIES' AS string)                          AS src_stm_code
    , CAST('ADDRESS' AS string)                                     AS adr_tp_code
    , CAST(address AS string)                                       AS adr_val
    , CAST(NULL AS string)                                          AS country_id
    , CAST(NULL AS string)                                          AS country_code
    , CAST(NULL AS string)                                          AS province_id
    , CAST(NULL AS string)                                          AS province_code
    , CAST(NULL AS string)                                          AS district_id
    , CAST(NULL AS string)                                          AS district_code
    , CAST(NULL AS string)                                          AS ward_id
    , CAST(NULL AS string)                                          AS ward_code
FROM le
