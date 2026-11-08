/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification IDS.IDENTITY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH iden AS (
    SELECT
        legal_entity_id
        , identity_type_cd
        , identity_no
        , identity_issued_date
        , identity_issued_place
    FROM {{ ref('ods_ids_identity') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "iden.legal_entity_id") }} AS ip_id
    , CAST(iden.legal_entity_id AS string)                                            AS ip_code
    , CAST('IDS_IDENTITY' AS string)                                                  AS src_stm_code
    , CAST('IDENTIFICATION' AS string)                                                AS identification_tp_code
    , CAST(iden.identity_no AS string)                                                AS identification_nbr
    , CAST(iden.identity_issued_date AS date)                                         AS identification_issue_dt
    , CAST(iden.identity_issued_place AS string)                                      AS identification_issue_place
FROM iden