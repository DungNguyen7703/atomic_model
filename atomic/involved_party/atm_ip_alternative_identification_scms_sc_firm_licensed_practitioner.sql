/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_LICENSED_PRACTITIONER
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date		User		Description
*
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_LICENSED_PRACTITIONER_IP_Alt_Identification.yaml (viet moi)
*--------------------------------------------------------------------*
*/

WITH sc_fi_li_pr AS (
    SELECT
        id
        , national_id
    FROM {{ ref('ods_scms_sc_firm_licensed_practitioner') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_LICENSED_PRACTITIONER', "sc_fi_li_pr.id") }} AS ip_id
    , CAST(sc_fi_li_pr.id AS string)                                                            AS ip_code
    , CAST('SCMS_SC_FIRM_LICENSED_PRACTITIONER' AS string)                                      AS src_stm_code
    , CAST('NATIONAL_ID' AS string)                                                             AS identification_tp_code
    , CAST(sc_fi_li_pr.national_id AS string)                                                   AS identification_nbr
    , CAST(NULL AS date)                                                                        AS identification_issue_dt
    , CAST(NULL AS string)                                                                      AS identification_issue_place
FROM sc_fi_li_pr