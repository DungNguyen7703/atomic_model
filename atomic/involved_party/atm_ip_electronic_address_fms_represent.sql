/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address FMS.REPRESENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH repr AS (
    SELECT
        id
        , email
        , fax
        , tel
    FROM {{ ref('ods_fms_represent') }}
),

unpvt AS (
    SELECT *
    FROM repr
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            email AS EMAIL,
            fax AS FAX,
            tel AS PHONE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_REPRESENT', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                       AS ip_code
    , CAST('FMS_REPRESENT' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                   AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                       AS electronic_adr_val
FROM unpvt