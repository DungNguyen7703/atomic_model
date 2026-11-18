/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address NHNCK.UNITS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH unit AS (
    SELECT
        id
        , unit_code
        , email
        , fax
        , phone_number
    FROM {{ ref('ods_nhnck_units') }}
),

unpvt AS (
    SELECT *
    FROM unit
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            email AS EMAIL,
            fax AS FAX,
            phone_number AS PHONE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_UNITS', "unpvt.id") }} AS ip_id
    , CAST(unpvt.unit_code AS string)                              AS ip_code
    , CAST('NHNCK_UNITS' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                 AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                     AS electronic_adr_val
FROM unpvt