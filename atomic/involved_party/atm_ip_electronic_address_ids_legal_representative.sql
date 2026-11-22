/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address IDS.LEGAL_REPRESENTATIVE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH le_re AS (
    SELECT
        id
        , phone_no
        , email
    FROM {{ ref('ods_ids_legal_representative') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_LEGAL_REPRESENTATIVE', "id") }} AS ip_id
    , CAST(id AS string)                                                  AS ip_code
    , CAST('IDS_LEGAL_REPRESENTATIVE' AS string)                          AS src_stm_code
    , CAST('PHONE' AS string)                                             AS electronic_adr_tp_code
    , CAST(phone_no AS string)                                            AS electronic_adr_val
FROM le_re
WHERE phone_no IS NOT NULL
UNION ALL
SELECT
    {{ generate_surrogate_key_bigint('IDS_LEGAL_REPRESENTATIVE', "id") }} AS ip_id
    , CAST(id AS string)                                                  AS ip_code
    , CAST('IDS_LEGAL_REPRESENTATIVE' AS string)                          AS src_stm_code
    , CAST('EMAIL' AS string)                                             AS electronic_adr_tp_code
    , CAST(email AS string)                                               AS electronic_adr_val
FROM le_re
WHERE email IS NOT NULL
