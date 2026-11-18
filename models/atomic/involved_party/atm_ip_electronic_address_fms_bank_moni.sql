/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address FMS.BANK_MONI
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ba_mo AS (
    SELECT
        id
        , email
        , fax
        , phone
        , website
    FROM {{ ref('ods_fms_bank_moni') }}
),

unpvt AS (
    SELECT *
    FROM ba_mo
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
    {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                       AS ip_code
    , CAST('FMS_BANK_MONI' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                   AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                       AS electronic_adr_val
FROM unpvt