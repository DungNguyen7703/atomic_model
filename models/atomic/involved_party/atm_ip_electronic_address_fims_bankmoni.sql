/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address_fims_bankmoni
* Program name: Atomic Involved Party Electronic Address FIMS.BANKMONI
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao model theo LLD FIMS_BANKMONI_IP_Electronic_Address.
*--------------------------------------------------------------------*
*/

WITH ba_mo AS (
    SELECT
        id
        , email
        , fax
        , telephone
        , website
    FROM {{ ref('ods_fims_bankmoni') }}
),

unpvt AS (
    SELECT *
    FROM ba_mo
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
    {{ generate_surrogate_key_bigint('FIMS_BANKMONI', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                         AS ip_code
    , CAST('FIMS_BANKMONI' AS string)                                  AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                     AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                         AS electronic_adr_val
FROM unpvt