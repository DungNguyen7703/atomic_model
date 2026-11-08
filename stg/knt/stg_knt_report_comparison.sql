/*
*--------------------------------------------------------------------*
* Program code: stg_knt_report_comparison
* Program name: Staging KNT.REPORT_COMPARISON
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                                AS id
    , CAST(tax_report_id AS int)                     AS tax_report_id
    , CAST(tax_report_detail_id AS int)              AS tax_report_detail_id
    , CAST(indicator_code AS string)                 AS indicator_code
    , CAST(indicator_name AS string)                 AS indicator_name
    , CAST(tax_explanation_note AS string)           AS tax_explanation_note
    , CAST(tax_year_end_value AS string)             AS tax_year_end_value
    , CAST(tax_year_begin_value AS string)           AS tax_year_begin_value
    , CAST(tax_current_year_value AS string)         AS tax_current_year_value
    , CAST(tax_prior_year_value AS string)           AS tax_prior_year_value
    , CAST(tax_sheet_name AS string)                 AS tax_sheet_name
    , CAST(tax_increase_prior_year AS string)        AS tax_increase_prior_year
    , CAST(tax_current_year_amount AS string)        AS tax_current_year_amount
    , CAST(tax_previous_year_amount AS string)       AS tax_previous_year_amount
    , CAST(tax_begin_balance_current_year AS string) AS tax_begin_balance_current_year
    , CAST(tax_end_balance_current_year AS string)   AS tax_end_balance_current_year
    , CAST(tax_end_balance_prior_year AS string)     AS tax_end_balance_prior_year
    , CAST(tax_begin_balance_prior_year AS string)   AS tax_begin_balance_prior_year
    , CAST(tax_increase_current_year AS string)      AS tax_increase_current_year
    , CAST(tax_decrease_current_year AS string)      AS tax_decrease_current_year
    , CAST(tax_decrease_prior_year AS string)        AS tax_decrease_prior_year
    , CAST(tax_declaration_period AS string)         AS tax_declaration_period
    , CAST(tax_declaration_code AS string)           AS tax_declaration_code
    , CAST(tax_code AS string)                       AS tax_code
    , CAST(ssc_report_id AS int)                     AS ssc_report_id
    , CAST(ssc_report_detail_id AS int)              AS ssc_report_detail_id
    , CAST(ssc_explanation_note AS string)           AS ssc_explanation_note
    , CAST(ssc_year_end_value AS string)             AS ssc_year_end_value
    , CAST(ssc_year_begin_value AS string)           AS ssc_year_begin_value
    , CAST(ssc_current_year_value AS string)         AS ssc_current_year_value
    , CAST(ssc_prior_year_value AS string)           AS ssc_prior_year_value
    , CAST(ssc_increase_prior_year AS string)        AS ssc_increase_prior_year
    , CAST(ssc_current_year_amount AS string)        AS ssc_current_year_amount
    , CAST(ssc_previous_year_amount AS string)       AS ssc_previous_year_amount
    , CAST(ssc_begin_balance_current_year AS string) AS ssc_begin_balance_current_year
    , CAST(ssc_end_balance_current_year AS string)   AS ssc_end_balance_current_year
    , CAST(ssc_end_balance_prior_year AS string)     AS ssc_end_balance_prior_year
    , CAST(ssc_begin_balance_prior_year AS string)   AS ssc_begin_balance_prior_year
    , CAST(ssc_increase_current_year AS string)      AS ssc_increase_current_year
    , CAST(ssc_decrease_current_year AS string)      AS ssc_decrease_current_year
    , CAST(ssc_decrease_prior_year AS string)        AS ssc_decrease_prior_year
    , CAST(ssc_report_type AS string)                AS ssc_report_type
    , CAST(diff_flag AS string)                      AS diff_flag
    , CAST(status AS int)                            AS status
    , CAST(total_records AS int)                     AS total_records
    , CAST(audit_status AS string)                   AS audit_status
    , CAST(report_comparison_header_id AS int)       AS report_comparison_header_id
FROM {{ source('source_knt', 'raw_report_comparison') }}