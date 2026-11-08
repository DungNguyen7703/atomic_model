/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address FMS.STF_FG_BRCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH st_fg_br AS (
    SELECT
        id
        , email
        , pl_email
    FROM {{ ref('ods_fms_stf_fg_brch') }}
),

unpvt AS (
    SELECT *
    FROM st_fg_br
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            email AS EMAIL,
            pl_email AS EMAIL_PERSONAL
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_STF_FG_BRCH', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                         AS ip_code
    , CAST('FMS_STF_FG_BRCH' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                     AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                         AS electronic_adr_val
FROM unpvt