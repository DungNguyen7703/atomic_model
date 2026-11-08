/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address FMS.INSIDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH insi AS (
    SELECT
        id
        , email
        , fax
        , telephone
    FROM {{ ref('ods_fms_insider') }}
),

unpvt AS (
    SELECT *
    FROM insi
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            email AS EMAIL,
            fax AS FAX,
            telephone AS PHONE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_INSIDER', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                     AS ip_code
    , CAST('FMS_INSIDER' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                 AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                     AS electronic_adr_val
FROM unpvt