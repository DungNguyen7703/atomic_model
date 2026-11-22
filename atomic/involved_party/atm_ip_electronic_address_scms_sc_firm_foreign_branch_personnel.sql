/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address SCMS.SC_FIRM_FOREIGN_BRANCH_PERSONNEL
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date		User		Description
*
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL_IP_Electronic_Address.yaml (khoi phuc tu 77a9749^)
*--------------------------------------------------------------------*
*/

WITH sc_fi_fo_br_pe AS (
    SELECT
        id
        , phone
        , email
        , disclosure_email
    FROM {{ ref('ods_scms_sc_firm_foreign_branch_personnel') }}
),

unpvt AS (
    SELECT *
    FROM sc_fi_fo_br_pe
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            phone AS PHONE,
            email AS EMAIL,
            disclosure_email AS EMAIL_DISCLOSURE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                                                 AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_BRANCH_PERSONNEL' AS string)                                  AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                                             AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                                                 AS electronic_adr_val
FROM unpvt