/*
*--------------------------------------------------------------------*
* Program code: atm_et_declaration_report_detail
* Program name: Atomic Et Declaration Report Detail
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao model theo lld_KNT_TAX_REPORT_DETAIL.yaml (Fact Append -> incremental_rebase append). UAT chua co model KNT nao.
*--------------------------------------------------------------------*
*/

WITH src AS (
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
    FROM {{ ref('ods_knt_tax_report_detail') }}
),

tr AS (
    SELECT
        id
        , declaration_code
    FROM {{ ref('ods_knt_tax_report') }}
)

SELECT
    {{ generate_surrogate_key_bigint('KNT_TAX_REPORT_DETAIL', "src.id") }}       AS et_declaration_rpt_detail_id
    , CAST(src.id AS string)                                                       AS et_declaration_rpt_detail_code
    , CAST('KNT_TAX_REPORT_DETAIL' AS string)                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('KNT_TAX_REPORT', "tr.declaration_code") }} AS et_declaration_rpt_id
    , CAST(tr.declaration_code AS string)                                          AS et_declaration_rpt_code
    , CAST(src.indicator_code AS string)                                           AS ind_code
    , CAST(src.indicator_name AS string)                                           AS ind_nm
    , CAST(src.explanation_note AS string)                                         AS explanation_note
    , CAST(src.sheet_name AS string)                                               AS sheet_nm_code
    , CAST(src.year_end_value AS string)                                           AS year_end_val
    , CAST(src.year_begin_value AS string)                                         AS year_begin_val
    , CAST(src.current_year_value AS string)                                       AS current_year_val
    , CAST(src.prior_year_value AS string)                                         AS prior_year_val
    , CAST(src.preparer_name AS string)                                            AS preparer_full_nm
    , CAST(src.chief_accountant AS string)                                         AS chief_accountant_full_nm
    , CAST(src.preparation_date AS string)                                         AS preparation_dt
    , CAST(src.director_name AS string)                                            AS director_full_nm
    , CAST(src.practice_cert_number AS string)                                     AS practice_certificate_nbr
    , CAST(src.audit_service_unit AS string)                                       AS audit_service_unit_nm
    , CAST(src.going_concern_yes AS string)                                        AS going_concern_yes_flag
    , CAST(src.going_concern_no AS string)                                         AS going_concern_no_flag
    , CAST(src.increase_prior_year AS string)                                      AS increase_prior_year_amt
    , CAST(src.current_year_amount AS string)                                      AS current_year_amt
    , CAST(src.previous_year_amount AS string)                                     AS previous_year_amt
    , CAST(src.begin_balance_current_year AS string)                               AS begin_balance_current_year_amt
    , CAST(src.end_balance_current_year AS string)                                 AS end_balance_current_year_amt
    , CAST(src.end_balance_prior_year AS string)                                   AS end_balance_prior_year_amt
    , CAST(src.begin_balance_prior_year AS string)                                 AS begin_balance_prior_year_amt
    , CAST(src.increase_current_year AS string)                                    AS increase_current_year_amt
    , CAST(src.decrease_current_year AS string)                                    AS decrease_current_year_amt
    , CAST(src.decrease_prior_year AS string)                                      AS decrease_prior_year_amt
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')                               AS data_dt
FROM src
    LEFT JOIN tr ON src.tax_report_id = tr.id
