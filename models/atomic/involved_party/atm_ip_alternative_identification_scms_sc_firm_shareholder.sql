/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_SHAREHOLDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_sh AS (
    SELECT
        id
        , id_number
    FROM {{ ref('ods_scms_sc_firm_shareholder') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SHAREHOLDER', "sc_fi_sh.id") }} AS ip_id
    , CAST(sc_fi_sh.id AS string)                                                  AS ip_code
    , CAST('SCMS_SC_FIRM_SHAREHOLDER' AS string)                                   AS src_stm_code
    , CAST('IDENTIFICATION' AS string)                                             AS identification_tp_code
    , CAST(sc_fi_sh.id_number AS string)                                           AS identification_nbr
    , CAST(NULL AS date)                                                           AS identification_issue_dt
    , CAST(NULL AS string)                                                         AS identification_issue_place
FROM sc_fi_sh