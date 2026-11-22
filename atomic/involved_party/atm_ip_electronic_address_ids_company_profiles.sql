/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address IDS.COMPANY_PROFILES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH co_pr AS (
    SELECT
        id
        , phone_no
        , fax_no
        , website
    FROM {{ ref('ods_ids_company_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "id") }} AS ip_id
    , CAST(id AS string)                                              AS ip_code
    , CAST('IDS_COMPANY_PROFILES' AS string)                          AS src_stm_code
    , CAST('PHONE' AS string)                                         AS electronic_adr_tp_code
    , CAST(phone_no AS string)                                        AS electronic_adr_val
FROM co_pr
WHERE phone_no IS NOT NULL
UNION ALL
SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "id") }} AS ip_id
    , CAST(id AS string)                                              AS ip_code
    , CAST('IDS_COMPANY_PROFILES' AS string)                          AS src_stm_code
    , CAST('FAX' AS string)                                           AS electronic_adr_tp_code
    , CAST(fax_no AS string)                                          AS electronic_adr_val
FROM co_pr
WHERE fax_no IS NOT NULL
UNION ALL
SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "id") }} AS ip_id
    , CAST(id AS string)                                              AS ip_code
    , CAST('IDS_COMPANY_PROFILES' AS string)                          AS src_stm_code
    , CAST('WEBSITE' AS string)                                       AS electronic_adr_tp_code
    , CAST(website AS string)                                          AS electronic_adr_val
FROM co_pr
WHERE website IS NOT NULL
