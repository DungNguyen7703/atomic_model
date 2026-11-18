/*
*--------------------------------------------------------------------*
* Program code: stg_fms_securities_report
* Program name: Staging FMS.SECURITIES_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu timestamp sang date (1 cot); kieu decimal(38,0) sang int (7 cot); kieu decimal(38,0) sang bigint (8 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                            AS id
    , HEX(sec_id)                                      AS sec_id
    , CAST(excution_date AS date)                      AS excution_date
    , CAST(period_type AS decimal(18,2))               AS period_type
    , CAST(total_personal_domestic AS int)             AS total_personal_domestic
    , CAST(total_organz_domestic AS int)               AS total_organz_domestic
    , CAST(total_personal_foreign AS int)              AS total_personal_foreign
    , CAST(total_organz_foreign AS int)                AS total_organz_foreign
    , CAST(ad_free_personal_domestic AS int)           AS ad_free_personal_domestic
    , CAST(advis_organz_domestic AS int)               AS advis_organz_domestic
    , CAST(advis_personal_foreign AS int)              AS advis_personal_foreign
    , CAST(advis_organz_foreign AS bigint)             AS advis_organz_foreign
    , CAST(period_report_fund_active AS string)        AS period_report_fund_active
    , CAST(revenue AS bigint)                          AS revenue
    , CAST(profit AS bigint)                           AS profit
    , CAST(cost AS bigint)                             AS cost
    , CAST(properties AS bigint)                       AS properties
    , CAST(period_report_finance AS string)            AS period_report_finance
    , CAST(capital_qtty AS bigint)                     AS capital_qtty
    , CAST(invest_long AS bigint)                      AS invest_long
    , CAST(invest_short AS bigint)                     AS invest_short
    , CAST(period_report_tlattc AS string)             AS period_report_tlattc
    , CAST(tlattc_value AS decimal(38,5))              AS tlattc_value
FROM {{ source('source_fms', 'raw_securities_report') }}