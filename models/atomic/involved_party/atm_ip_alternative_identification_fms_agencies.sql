/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.AGENCIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH agen AS (
    SELECT
        id
        , decision
        , decision_date
        , decision_place
    FROM {{ ref('ods_fms_agencies') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_AGENCIES', "agen.id") }} AS ip_id
    , CAST(agen.id AS string)                                      AS ip_code
    , CAST('FMS_AGENCIES' AS string)                               AS src_stm_code
    , CAST('ESTABLISHMENT_OPERATION_LICENSE' AS string)            AS identification_tp_code
    , CAST(agen.decision AS string)                                AS identification_nbr
    , CAST(agen.decision_date AS date)                             AS identification_issue_dt
    , CAST(agen.decision_place AS string)                          AS identification_issue_place
FROM agen