/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address FIMS.INVESTOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH inve AS (
    SELECT
        transactioncode
        , email
        , fax
        , telephone
        , website
    FROM {{ ref('ods_fims_investor') }}
),

unpvt AS (
    SELECT *
    FROM inve
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
    {{ generate_surrogate_key_bigint('FIMS_INVESTOR', "unpvt.transactioncode") }} AS ip_id
    , CAST(unpvt.transactioncode AS string)                                       AS ip_code
    , CAST('FIMS_INVESTOR' AS string)                                             AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                                AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                                    AS electronic_adr_val
FROM unpvt