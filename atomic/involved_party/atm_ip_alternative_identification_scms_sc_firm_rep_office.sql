/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_REP_OFFICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_re_of AS (
    SELECT
        id
        , decision_number
        , decision_date
        , record_status
    FROM {{ ref('ods_scms_sc_firm_rep_office') }}
    where record_status = 1
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_REP_OFFICE', "sc_fi_re_of.id") }} AS ip_id
    , CAST(sc_fi_re_of.id AS string)                                                 AS ip_code
    , CAST('SCMS_SC_FIRM_REP_OFFICE' AS string)                                      AS src_stm_code
    , CAST('ESTABLISHMENT_OPERATION_LICENSE' AS string)                              AS identification_tp_code
    , CAST(sc_fi_re_of.decision_number AS string)                                    AS identification_nbr
    , CAST(sc_fi_re_of.decision_date AS date)                                        AS identification_issue_dt
    , CAST(NULL AS string)                                                           AS identification_issue_place
FROM sc_fi_re_of