/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification NHNCK.IDENTITY_INFO_C06S
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH id_in_c0 AS (
    SELECT
        distinct(identity_number)
    FROM {{ ref('ods_nhnck_identity_info_c06s') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_IDENTITY_INFO_C06S', "id_in_c0.identity_number") }} AS ip_id
    , CAST(id_in_c0.identity_number AS string)                                                    AS ip_code
    , CAST('NHNCK_IDENTITY_INFO_C06S' AS string)                                                    AS src_stm_code
    , CAST('NATIONAL_ID' AS string)                                                               AS identification_tp_code
    , CAST(id_in_c0.identity_number AS string)                                                    AS identification_nbr
    , CAST(NULL AS date)                                                                          AS identification_issue_dt
    , CAST(NULL AS string)                                                                        AS identification_issue_place
FROM id_in_c0