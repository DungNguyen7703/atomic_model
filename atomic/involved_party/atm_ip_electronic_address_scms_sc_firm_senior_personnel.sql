/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address SCMS.SC_FIRM_SENIOR_PERSONNEL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_se_pe AS (
    SELECT
        id
        , email
        , disclosure_email
        , fax
        , phone
    FROM {{ ref('ods_scms_sc_firm_senior_personnel') }}
),

unpvt AS (
    SELECT *
    FROM sc_fi_se_pe
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            email AS EMAIL,
            disclosure_email AS EMAIL_DISCLOSURE,
            fax AS FAX,
            phone AS PHONE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SENIOR_PERSONNEL', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                                       AS ip_code
    , CAST('SCMS_SC_FIRM_SENIOR_PERSONNEL' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                                   AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                                       AS electronic_adr_val
FROM unpvt