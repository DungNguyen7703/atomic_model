/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address SCMS.BANK
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date		User		Description
*
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_BANK_IP_Electronic_Address.yaml (khoi phuc tu 77a9749^)
*--------------------------------------------------------------------*
*/

WITH ba AS (
    SELECT
        id
        , phone
        , fax
        , email
        , website
    FROM {{ ref('ods_scms_bank') }}
),

unpvt AS (
    SELECT *
    FROM ba
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            phone AS PHONE,
            fax AS FAX,
            email AS EMAIL,
            website AS WEBSITE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_BANK', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                     AS ip_code
    , CAST('SCMS_BANK' AS string)                                  AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                 AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                     AS electronic_adr_val
FROM unpvt