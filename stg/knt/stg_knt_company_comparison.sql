/*
*--------------------------------------------------------------------*
* Program code: stg_knt_company_comparison
* Program name: Staging KNT.COMPANY_COMPARISON
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                               AS id
    , CAST(company_info_id AS int)                  AS company_info_id
    , CAST(tax_registration_id AS int)              AS tax_registration_id
    , CAST(tax_code AS string)                      AS tax_code
    , CAST(ssc_name AS string)                      AS ssc_name
    , CAST(ssc_address AS string)                   AS ssc_address
    , CAST(ssc_phone AS string)                     AS ssc_phone
    , CAST(ssc_fax AS string)                       AS ssc_fax
    , CAST(ssc_website AS string)                   AS ssc_website
    , CAST(ssc_business_line AS string)             AS ssc_business_line
    , CAST(ssc_legal_representative_name AS string) AS ssc_legal_representative_name
    , CAST(ssc_charter_capital AS int)              AS ssc_charter_capital
    , CAST(ssc_decision_number AS string)           AS ssc_decision_number
    , CAST(ssc_business_license AS string)          AS ssc_business_license
    , CAST(tax_name AS string)                      AS tax_name
    , CAST(tax_address AS string)                   AS tax_address
    , CAST(tax_phone AS string)                     AS tax_phone
    , CAST(tax_fax AS string)                       AS tax_fax
    , CAST(tax_website AS string)                   AS tax_website
    , CAST(tax_business_line AS string)             AS tax_business_line
    , CAST(tax_legal_representative_name AS string) AS tax_legal_representative_name
    , CAST(tax_charter_capital AS int)              AS tax_charter_capital
    , CAST(tax_decision_number AS string)           AS tax_decision_number
    , CAST(tax_business_license AS string)          AS tax_business_license
    , CAST(diff_flag AS int)                        AS diff_flag
    , CAST(comparison_date AS date)                 AS comparison_date
FROM {{ source('source_knt', 'raw_company_comparison') }}