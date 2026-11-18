/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address FMS.AGENCIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH agen AS (
    SELECT
        id
        , fax
        , telephone
    FROM {{ ref('ods_fms_agencies') }}
),

unpvt AS (
    SELECT *
    FROM agen
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            fax AS FAX,
            telephone AS PHONE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_AGENCIES', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                      AS ip_code
    , CAST('FMS_AGENCIES' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                  AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                      AS electronic_adr_val
FROM unpvt