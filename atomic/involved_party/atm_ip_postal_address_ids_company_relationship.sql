/*
*--------------------------------------------------------------------*
* Program code: atm_ip_postal_address
* Program name: Atomic Involved Party Postal Address IDS.COMPANY_RELATIONSHIP
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH co_re AS (
    SELECT
        id
        , head_office_addr
    FROM {{ ref('ods_ids_company_relationship') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_RELATIONSHIP', "id") }} AS ip_id
    , CAST(id AS string)                                                  AS ip_code
    , CAST('IDS_COMPANY_RELATIONSHIP' AS string)                          AS src_stm_code
    , CAST('HEAD_OFFICE' AS string)                                       AS adr_tp_code
    , CAST(head_office_addr AS string)                                    AS adr_val
    , CAST(NULL AS string)                                                AS country_id
    , CAST(NULL AS string)                                                AS country_code
    , CAST(NULL AS string)                                                AS province_id
    , CAST(NULL AS string)                                                AS province_code
    , CAST(NULL AS string)                                                AS district_id
    , CAST(NULL AS string)                                                AS district_code
    , CAST(NULL AS string)                                                AS ward_id
    , CAST(NULL AS string)                                                AS ward_code
FROM co_re
