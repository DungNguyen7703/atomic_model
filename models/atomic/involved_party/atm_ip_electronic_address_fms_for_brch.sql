/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address FMS.FOR_BRCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH fo_br AS (
    SELECT
        id,
        email,
        fax,
        phone,
        website
    FROM {{ ref('ods_fms_for_brch') }}
),

unpvt AS (
    SELECT *
    FROM fo_br
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
    {{ generate_surrogate_key_bigint('FMS_FOR_BRCH', "id") }} AS ip_id,
    CAST(id AS string)                                        AS ip_code,
    CAST('FMS_FOR_BRCH' AS string)                            AS src_stm_code,
    CAST(electronic_adr_tp_code AS string)                    AS electronic_adr_tp_code,
    CAST(electronic_adr_val AS string)                        AS electronic_adr_val
FROM unpvt