/*
*--------------------------------------------------------------------*
* Program code: ods_knt_tax_report_detail
* Program name: ODS KNT.TAX_REPORT_DETAIL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-11-12		ngoc.pham		Bo cot data_dt khoi SELECT cho khop DDL (Truncate then Insert)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , tax_report_id
    , indicator_code
    , indicator_name
    , explanation_note
    , year_end_value
    , year_begin_value
    , current_year_value
    , prior_year_value
    , sheet_name
    , preparer_name
    , chief_accountant
    , preparation_date
    , director_name
    , practice_cert_number
    , audit_service_unit
    , going_concern_yes
    , going_concern_no
    , increase_prior_year
    , current_year_amount
    , previous_year_amount
    , begin_balance_current_year
    , end_balance_current_year
    , end_balance_prior_year
    , begin_balance_prior_year
    , increase_current_year
    , decrease_current_year
    , decrease_prior_year
FROM {{ ref('stg_knt_tax_report_detail') }}