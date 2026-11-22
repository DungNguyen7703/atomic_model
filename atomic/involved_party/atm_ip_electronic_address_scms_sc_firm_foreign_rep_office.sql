/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address SCMS.SC_FIRM_FOREIGN_REP_OFFICE
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date		User		Description
*
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_FOREIGN_REP_OFFICE_IP_Electronic_Address.yaml (khoi phuc tu 77a9749^)
*--------------------------------------------------------------------*
*/

WITH sc_fi_fo_re_of AS (
    SELECT
        id
        , phone
        , fax
        , email
    FROM {{ ref('ods_scms_sc_firm_foreign_rep_office') }}
),

unpvt AS (
    SELECT *
    FROM sc_fi_fo_re_of
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
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_REP_OFFICE', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                                           AS ip_code
    , CAST('SCMS_SC_FIRM_FOREIGN_REP_OFFICE' AS string)                                  AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                                       AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                                           AS electronic_adr_val
FROM unpvt