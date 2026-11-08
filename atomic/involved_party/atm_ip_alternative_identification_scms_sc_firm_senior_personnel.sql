/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_SENIOR_PERSONNEL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_se_pe AS (
    SELECT
        id
        , issue_place
        , id_number
        , issue_date
        , securities_license_number
        , securities_license_date
    FROM {{ ref('ods_scms_sc_firm_senior_personnel') }}
),

unpvt AS (
    SELECT *
    FROM sc_fi_se_pe
    UNPIVOT (
        (identification_nbr, identification_issue_dt)
        FOR identification_tp_code IN (
            (id_number, issue_date) AS IDENTIFICATION,
            (securities_license_number, securities_license_date) AS PRACTITIONER_LICENSE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SENIOR_PERSONNEL', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                                       AS ip_code
    , CAST('SCMS_SC_FIRM_SENIOR_PERSONNEL' AS string)                                AS src_stm_code
    , CAST(unpvt.identification_tp_code AS string)                                   AS identification_tp_code
    , CAST(unpvt.identification_nbr AS string)                                       AS identification_nbr
    , CAST(unpvt.identification_issue_dt AS date)                                    AS identification_issue_dt
    , CAST(unpvt.issue_place AS string)                                              AS identification_issue_place
FROM unpvt