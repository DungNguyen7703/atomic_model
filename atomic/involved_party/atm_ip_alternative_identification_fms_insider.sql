/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.INSIDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH insi AS (
    SELECT
        id
        , id_no
        , id_date
        , id_add
    FROM {{ ref('ods_fms_insider') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_INSIDER', "insi.id") }} AS ip_id
    , CAST(insi.id AS string)                                     AS ip_code
    , CAST('FMS_INSIDER' AS string)                               AS src_stm_code
    , CAST('IDENTIFICATION' AS string)                            AS identification_tp_code
    , CAST(insi.id_no AS string)                                  AS identification_nbr
    , CAST(insi.id_date AS date)                                  AS identification_issue_dt
    , CAST(insi.id_add AS string)                                 AS identification_issue_place
FROM insi