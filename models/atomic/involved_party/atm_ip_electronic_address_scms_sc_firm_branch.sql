/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address SCMS.SC_FIRM_BRANCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_br AS (
    SELECT
        id
        , email
        , fax
        , phone
        , website
    FROM {{ ref('ods_scms_sc_firm_branch') }}
),

unpvt AS (
    SELECT *
    FROM sc_fi_br
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
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                             AS ip_code
    , CAST('SCMS_SC_FIRM_BRANCH' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                         AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                             AS electronic_adr_val
FROM unpvt