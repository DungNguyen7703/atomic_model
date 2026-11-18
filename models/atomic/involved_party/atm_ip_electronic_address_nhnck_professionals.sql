/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address NHNCK.PROFESSIONALS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pro AS (
    SELECT
        id
        , email
        , mobile_number
        , phone_number
    FROM {{ ref('ods_nhnck_professionals') }}
),

unpvt AS (
    SELECT *
    FROM pro
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            email AS EMAIL,
            mobile_number AS MOBILE,
            phone_number AS PHONE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                             AS ip_code
    , CAST('NHNCK_PROFESSIONALS' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                         AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                             AS electronic_adr_val
FROM unpvt