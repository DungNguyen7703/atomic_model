/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address SCMS.SC_FIRM_INFO
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_in AS (
    SELECT
        id
        , code
        , email
        , fax
        , phone
        , website
    FROM {{ ref('ods_scms_sc_firm_info') }}
),

unpvt AS (
    SELECT *
    FROM sc_fi_in
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            email AS EMAIL,
            fax AS FAX,
            phone AS PHONE,
            website AS WEBSITE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "unpvt.code") }} AS ip_id
    , CAST(unpvt.code AS string)                                           AS ip_code
    , CAST('SCMS_SC_FIRM_INFO' AS string)                                  AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                         AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                             AS electronic_adr_val
FROM unpvt