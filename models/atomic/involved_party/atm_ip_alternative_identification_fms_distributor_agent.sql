/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.DISTRIBUTOR_AGENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH di_ag AS (
    SELECT
        id
        , business_license_no
        , license_issue_date
        , license_issued_by
        , tax_code
        , CAST(NULL AS date)   AS tax_issue_dt
        , CAST(NULL AS string) AS tax_issue_place
        , distribution_cert_no
        , distribution_cert_date
        , distribution_cert_issued_by
        , tax_code
    FROM {{ ref('ods_fms_distributor_agent') }}
),

unpvt AS (
    SELECT *
    FROM di_ag
    UNPIVOT (
        (identification_nbr, identification_issue_dt, identification_issue_place)
        FOR identification_tp_code IN (
            (business_license_no, license_issue_date, license_issued_by) AS BUSINESS_LICENSE,
            (tax_code, tax_issue_dt, tax_issue_place) AS TAX_ID,
            (distribution_cert_no, distribution_cert_date, distribution_cert_issued_by) AS ESTABLISHMENT_OPERATION_LICENSE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_DISTRIBUTOR_AGENT', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                               AS ip_code
    , CAST('FMS_DISTRIBUTOR_AGENT' AS string)                                AS src_stm_code
    , CAST(unpvt.identification_tp_code AS string)                           AS identification_tp_code
    , CAST(unpvt.identification_nbr AS string)                               AS identification_nbr
    , CAST(unpvt.identification_issue_dt AS date)                            AS identification_issue_dt
    , CAST(unpvt.identification_issue_place AS string)                       AS identification_issue_place
FROM unpvt