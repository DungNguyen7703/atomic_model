/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification_fms_pension_provider
* Program name: Atomic IP Alternative Identification FMS.PENSION_PROVIDER
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao nhanh FMS theo lld_FMS_PENSION_PROVIDER_IP_Alt_Identification.yaml (UAT chua co).
*--------------------------------------------------------------------*
*/

WITH pp AS (
    SELECT
        id
        , business_license_no
        , license_issue_date
        , license_issued_by
        , tax_code
    FROM {{ ref('ods_fms_pension_provider') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_PENSION_PROVIDER', "pp.id") }} AS ip_id
    , CAST(pp.id AS string)                                                AS ip_code
    , CAST('FMS_PENSION_PROVIDER' AS string)                               AS src_stm_code
    , CAST('BUSINESS_LICENSE' AS string)                                   AS identification_tp_code
    , CAST(pp.business_license_no AS string)                               AS identification_nbr
    , CAST(pp.license_issue_date AS date)                                  AS identification_issue_dt
    , CAST(pp.license_issued_by AS string)                                 AS identification_issue_place
FROM pp
WHERE pp.business_license_no IS NOT NULL

UNION ALL

SELECT
    {{ generate_surrogate_key_bigint('FMS_PENSION_PROVIDER', "pp.id") }} AS ip_id
    , CAST(pp.id AS string)                                                AS ip_code
    , CAST('FMS_PENSION_PROVIDER' AS string)                               AS src_stm_code
    , CAST('TAX_ID' AS string)                                             AS identification_tp_code
    , CAST(pp.tax_code AS string)                                          AS identification_nbr
    , CAST(NULL AS date)                                                   AS identification_issue_dt
    , CAST(NULL AS string)                                                 AS identification_issue_place
FROM pp
WHERE pp.tax_code IS NOT NULL
