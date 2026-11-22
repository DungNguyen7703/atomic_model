/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address SCMS.SC_FIRM_FOREIGN_BRANCH
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date		User		Description
*
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_FOREIGN_BRANCH_IP_Electronic_Address.yaml (khoi phuc tu 77a9749^)
*--------------------------------------------------------------------*
*/

WITH sc_fi_fo_br AS (
    SELECT
        id
        , phone
        , fax
        , email
    FROM {{ ref('ods_scms_sc_firm_foreign_branch') }}
),

unpvt AS (
    SELECT *
    FROM sc_fi_fo_br
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            phone AS PHONE,
            fax AS FAX,
            email AS EMAIL
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                                       AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_BRANCH' AS string)                                  AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                                   AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                                       AS electronic_adr_val
FROM unpvt