/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_FOREIGN_BRANCH
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-25		tuan.nguyenvanb		[LLD SCMS lld_SCMS_SC_FIRM_FOREIGN_BRANCH_IP_Alt_Identification.yaml] Tao moi model con theo LLD
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , license_number
        , license_date
        , enterprise_code
        , tax_code
        , business_reg_cert
        , business_reg_cert_date
    FROM {{ ref('ods_scms_sc_firm_foreign_branch') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH', "fb.id") }} AS ip_id
    , CAST(fb.id AS string)                                                       AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_BRANCH' AS string)                               AS src_stm_code
    , CAST('ESTABLISHMENT_OPERATION_LICENSE' AS string)                           AS identification_tp_code
    , CAST(fb.license_number AS string)                                           AS identification_nbr
    , CAST(fb.license_date AS date)                                               AS identification_issue_dt
    , CAST(NULL AS string)                                                        AS identification_issue_place
FROM src AS fb
WHERE fb.license_number IS NOT NULL

UNION ALL

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH', "fb.id") }} AS ip_id
    , CAST(fb.id AS string)                                                       AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_BRANCH' AS string)                               AS src_stm_code
    , CAST('ENTERPRISE_CODE' AS string)                                           AS identification_tp_code
    , CAST(fb.enterprise_code AS string)                                          AS identification_nbr
    , CAST(NULL AS date)                                                          AS identification_issue_dt
    , CAST(NULL AS string)                                                        AS identification_issue_place
FROM src AS fb
WHERE fb.enterprise_code IS NOT NULL

UNION ALL

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH', "fb.id") }} AS ip_id
    , CAST(fb.id AS string)                                                       AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_BRANCH' AS string)                               AS src_stm_code
    , CAST('TAX_ID' AS string)                                                    AS identification_tp_code
    , CAST(fb.tax_code AS string)                                                 AS identification_nbr
    , CAST(NULL AS date)                                                          AS identification_issue_dt
    , CAST(NULL AS string)                                                        AS identification_issue_place
FROM src AS fb
WHERE fb.tax_code IS NOT NULL

UNION ALL

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH', "fb.id") }} AS ip_id
    , CAST(fb.id AS string)                                                       AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_BRANCH' AS string)                               AS src_stm_code
    , CAST('BUSINESS_LICENSE' AS string)                                          AS identification_tp_code
    , CAST(fb.business_reg_cert AS string)                                        AS identification_nbr
    , CAST(fb.business_reg_cert_date AS date)                                     AS identification_issue_dt
    , CAST(NULL AS string)                                                        AS identification_issue_place
FROM src AS fb
WHERE fb.business_reg_cert IS NOT NULL
