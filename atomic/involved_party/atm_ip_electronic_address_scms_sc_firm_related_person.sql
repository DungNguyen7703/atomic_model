/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address SCMS.SC_FIRM_RELATED_PERSON
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_re_pe AS (
    SELECT
        id
        , email
        , phone
    FROM {{ ref('ods_scms_sc_firm_related_person') }}
),

unpvt AS (
    SELECT *
    FROM sc_fi_re_pe
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            email AS EMAIL,
            phone AS PHONE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_RELATED_PERSON', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                                     AS ip_code
    , CAST('SCMS_SC_FIRM_RELATED_PERSON' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                                 AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                                     AS electronic_adr_val
FROM unpvt