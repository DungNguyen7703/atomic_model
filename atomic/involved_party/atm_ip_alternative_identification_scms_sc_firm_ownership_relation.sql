/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_OWNERSHIP_RELATION
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date		User		Description
*
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_OWNERSHIP_RELATION_IP_Alt_Identification.yaml (viet moi)
*--------------------------------------------------------------------*
*/

WITH sc_fi_ow_re AS (
    SELECT
        id
        , enterprise_code
    FROM {{ ref('ods_scms_sc_firm_ownership_relation') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_OWNERSHIP_RELATION', "sc_fi_ow_re.id") }} AS ip_id
    , CAST(sc_fi_ow_re.id AS string)                                                           AS ip_code
    , CAST('SCMS_SC_FIRM_OWNERSHIP_RELATION' AS string)                                        AS src_stm_code
    , CAST('ENTERPRISE_CODE' AS string)                                                        AS identification_tp_code
    , CAST(sc_fi_ow_re.enterprise_code AS string)                                              AS identification_nbr
    , CAST(NULL AS date)                                                                       AS identification_issue_dt
    , CAST(NULL AS string)                                                                     AS identification_issue_place
FROM sc_fi_ow_re
WHERE sc_fi_ow_re.enterprise_code IS NOT NULL