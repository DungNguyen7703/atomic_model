/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.MB_FUND
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH mb_fu AS (
    SELECT
        id
        , id_no
        , id_date
    FROM {{ ref('ods_fms_mb_fund') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_MB_FUND', "mb_fu.id") }} AS ip_id
    , CAST(mb_fu.id AS string)                                     AS ip_code
    , CAST('FMS_MB_FUND' AS string)                                AS src_stm_code
    , CAST('NATIONAL_ID' AS string)                                AS identification_tp_code
    , CAST(mb_fu.id_no AS string)                                  AS identification_nbr
    , CAST(mb_fu.id_date AS date)                                  AS identification_issue_dt
    , CAST(NULL AS string)                                         AS identification_issue_place
FROM mb_fu