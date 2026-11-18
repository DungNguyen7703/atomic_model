/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_FOREIGN_REP_OFFICE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-25		tuan.nguyenvanb		[LLD SCMS lld_SCMS_SC_FIRM_FOREIGN_REP_OFFICE_IP_Alt_Identification.yaml] Tao moi model con theo LLD
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , license_number
        , license_date
        , enterprise_code
        , tax_code
    FROM {{ ref('ods_scms_sc_firm_foreign_rep_office') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_REP_OFFICE', "fr.id") }} AS ip_id
    , CAST(fr.id AS string)                                                           AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_REP_OFFICE' AS string)                               AS src_stm_code
    , CAST('ESTABLISHMENT_OPERATION_LICENSE' AS string)                               AS identification_tp_code
    , CAST(fr.license_number AS string)                                               AS identification_nbr
    , CAST(fr.license_date AS date)                                                   AS identification_issue_dt
    , CAST(NULL AS string)                                                            AS identification_issue_place
FROM src AS fr
WHERE fr.license_number IS NOT NULL

UNION ALL

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_REP_OFFICE', "fr.id") }} AS ip_id
    , CAST(fr.id AS string)                                                           AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_REP_OFFICE' AS string)                               AS src_stm_code
    , CAST('ENTERPRISE_CODE' AS string)                                               AS identification_tp_code
    , CAST(fr.enterprise_code AS string)                                              AS identification_nbr
    , CAST(NULL AS date)                                                              AS identification_issue_dt
    , CAST(NULL AS string)                                                            AS identification_issue_place
FROM src AS fr
WHERE fr.enterprise_code IS NOT NULL

UNION ALL

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_REP_OFFICE', "fr.id") }} AS ip_id
    , CAST(fr.id AS string)                                                           AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_REP_OFFICE' AS string)                               AS src_stm_code
    , CAST('TAX_ID' AS string)                                                        AS identification_tp_code
    , CAST(fr.tax_code AS string)                                                     AS identification_nbr
    , CAST(NULL AS date)                                                              AS identification_issue_dt
    , CAST(NULL AS string)                                                            AS identification_issue_place
FROM src AS fr
WHERE fr.tax_code IS NOT NULL
