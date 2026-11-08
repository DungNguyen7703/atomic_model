/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.REPRESENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-07		claude				identification_tp_code: NATIONAL_ID -> IDENTIFICATION; identification_issue_place = PROVINCE
*										theo LLD REPRESENT_IP_Alt_Identification
*--------------------------------------------------------------------*
*/

WITH repr AS (
    SELECT
        id
        , id_no
        , id_date
        , province
    FROM {{ ref('ods_fms_represent') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_REPRESENT', "repr.id") }} AS ip_id
    , CAST(repr.id AS string)                                       AS ip_code
    , CAST('FMS_REPRESENT' AS string)                               AS src_stm_code
    , CAST('IDENTIFICATION' AS string)                              AS identification_tp_code
    , CAST(repr.id_no AS string)                                    AS identification_nbr
    , CAST(repr.id_date AS date)                                    AS identification_issue_dt
    , CAST(repr.province AS string)                                 AS identification_issue_place
FROM repr