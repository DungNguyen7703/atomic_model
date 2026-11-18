/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address NHNCK.ORGANIZATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH org AS (
    SELECT
        id
        , email
        , fax
        , mobile_number
        , phone_number
        , website
    FROM {{ ref('ods_nhnck_organizations') }}
),

unpvt AS (
    SELECT *
    FROM org
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            email AS EMAIL,
            fax AS FAX,
            mobile_number AS MOBILE,
            phone_number AS PHONE,
            website AS WEBSITE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_ORGANIZATIONS', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                             AS ip_code
    , CAST('NHNCK_ORGANIZATIONS' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                         AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                             AS electronic_adr_val
FROM unpvt