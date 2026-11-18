/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FIMS.TRADINGREPRESENTATIVE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH tr_re AS (
    SELECT
        id
        , idno
    FROM {{ ref('ods_fims_tradingrepresentative') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_TRADINGREPRESENTATIVE', "tr_re.id") }} AS ip_id
    , CAST(tr_re.id AS string)                                                      AS ip_code
    , CAST('FIMS_TRADINGREPRESENTATIVE' AS string)                                    AS src_stm_code
    , CAST('NATIONAL_ID' AS string)                                                 AS identification_tp_code
    , CAST(tr_re.idno AS string)                                                    AS identification_nbr
    , CAST(NULL AS date)                                                            AS identification_issue_dt
    , CAST(NULL AS string)                                                          AS identification_issue_place
FROM tr_re