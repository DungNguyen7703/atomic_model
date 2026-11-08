/*
*--------------------------------------------------------------------*
* Program code: stg_knt_ssc_report_detail
* Program name: Staging KNT.SSC_REPORT_DETAIL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(ssc_report_id AS int)                 AS ssc_report_id
    , CAST(indicator_code AS string)             AS indicator_code
    , CAST(indicator_name AS string)             AS indicator_name
    , CAST(explanation_note AS string)           AS explanation_note
    , CAST(year_end_value AS string)             AS year_end_value
    , CAST(year_begin_value AS string)           AS year_begin_value
    , CAST(current_year_value AS string)         AS current_year_value
    , CAST(prior_year_value AS string)           AS prior_year_value
    , CAST(sheet_name AS string)                 AS sheet_name
    , CAST(preparer_name AS string)              AS preparer_name
    , CAST(chief_accountant AS string)           AS chief_accountant
    , CAST(preparation_date AS string)           AS preparation_date
    , CAST(director_name AS string)              AS director_name
    , CAST(practice_cert_number AS string)       AS practice_cert_number
    , CAST(audit_service_unit AS string)         AS audit_service_unit
    , CAST(begin_balance_current_year AS string) AS begin_balance_current_year
    , CAST(begin_balance_prior_year AS string)   AS begin_balance_prior_year
    , CAST(increase_prior_year AS string)        AS increase_prior_year
    , CAST(decrease_prior_year AS string)        AS decrease_prior_year
    , CAST(increase_current_year AS string)      AS increase_current_year
    , CAST(decrease_current_year AS string)      AS decrease_current_year
    , CAST(end_balance_prior_year AS string)     AS end_balance_prior_year
    , CAST(end_balance_current_year AS string)   AS end_balance_current_year
    , CAST(total_current_year AS string)         AS total_current_year
    , CAST(total_prior_year AS string)           AS total_prior_year
    , CAST(current_year_amount AS string)        AS current_year_amount
    , CAST(previous_year_amount AS string)       AS previous_year_amount
    , CAST(thutu AS int)                         AS thutu
FROM {{ source('source_knt', 'raw_ssc_report_detail') }}