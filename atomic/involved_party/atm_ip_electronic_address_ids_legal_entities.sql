/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address IDS.LEGAL_ENTITIES
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
        , phone_no
        , fax_no
        , website
    FROM {{ ref('ods_ids_legal_entities') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "id") }} AS ip_id
    , CAST(id AS string)                                            AS ip_code
    , CAST('IDS_LEGAL_ENTITIES' AS string)                          AS src_stm_code
    , CAST('PHONE' AS string)                                       AS electronic_adr_tp_code
    , CAST(phone_no AS string)                                      AS electronic_adr_val
FROM le
WHERE phone_no IS NOT NULL
UNION ALL
SELECT
    {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "id") }} AS ip_id
    , CAST(id AS string)                                            AS ip_code
    , CAST('IDS_LEGAL_ENTITIES' AS string)                          AS src_stm_code
    , CAST('FAX' AS string)                                         AS electronic_adr_tp_code
    , CAST(fax_no AS string)                                        AS electronic_adr_val
FROM le
WHERE fax_no IS NOT NULL
UNION ALL
SELECT
    {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "id") }} AS ip_id
    , CAST(id AS string)                                            AS ip_code
    , CAST('IDS_LEGAL_ENTITIES' AS string)                          AS src_stm_code
    , CAST('WEBSITE' AS string)                                     AS electronic_adr_tp_code
    , CAST(website AS string)                                       AS electronic_adr_val
FROM le
WHERE website IS NOT NULL
