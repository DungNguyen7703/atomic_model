/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address FMS.SECURITIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH secu AS (
    SELECT
        id
        , email
        , fax
        , telephone
        , website
    FROM {{ ref('ods_fms_securities') }}
),

unpvt AS (
    SELECT *
    FROM secu
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            email AS EMAIL,
            fax AS FAX,
            telephone AS PHONE,
            website AS WEBSITE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_SECURITIES', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                        AS ip_code
    , CAST('FMS_SECURITIES' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                    AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                        AS electronic_adr_val
FROM unpvt