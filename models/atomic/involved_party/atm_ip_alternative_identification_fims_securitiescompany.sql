/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FIMS.SECURITIESCOMPANY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH se_co AS (
    SELECT
        id
        , regno
        , regdate
        , regadd
        , depcert
        , CAST(NULL AS date)   AS depdate
        , CAST(NULL AS string) AS depadd
        , idno
        , iddate
        , idadd
    FROM {{ ref('ods_fims_securitiescompany') }}
),

unpvt AS (
    SELECT *
    FROM se_co
    UNPIVOT (
        (identification_nbr, identification_issue_dt, identification_issue_place)
        FOR identification_tp_code IN (
            (regno, regdate, regadd) AS BUSINESS_LICENSE,
            (depcert, depdate, depadd) AS CUSTODIAN_MEMBER_CERTIFICATE,
            (idno, iddate, idadd) AS ESTABLISHMENT_OPERATION_LICENSE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_SECURITIESCOMPANY', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                                AS ip_code
    , CAST('FIMS_SECURITIESCOMPANY' AS string)                                AS src_stm_code
    , CAST(unpvt.identification_tp_code AS string)                            AS identification_tp_code
    , CAST(unpvt.identification_nbr AS string)                                AS identification_nbr
    , CAST(unpvt.identification_issue_dt AS date)                             AS identification_issue_dt
    , CAST(unpvt.identification_issue_place AS string)                        AS identification_issue_place
FROM unpvt