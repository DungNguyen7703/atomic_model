/*
*--------------------------------------------------------------------*
* Program code: stg_fms_securities_report
* Program name: Staging FMS.SECURITIES_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                            AS id
    , HEX(sec_id)                                      AS sec_id
    , CAST(excution_date AS timestamp)                 AS excution_date
    , CAST(period_type AS decimal(18,2))               AS period_type
    , CAST(total_personal_domestic AS decimal(38,0))   AS total_personal_domestic
    , CAST(total_organz_domestic AS decimal(38,0))     AS total_organz_domestic
    , CAST(total_personal_foreign AS decimal(38,0))    AS total_personal_foreign
    , CAST(total_organz_foreign AS decimal(38,0))      AS total_organz_foreign
    , CAST(ad_free_personal_domestic AS decimal(38,0)) AS ad_free_personal_domestic
    , CAST(advis_organz_domestic AS decimal(38,0))     AS advis_organz_domestic
    , CAST(advis_personal_foreign AS decimal(38,0))    AS advis_personal_foreign
    , CAST(advis_organz_foreign AS decimal(38,0))      AS advis_organz_foreign
    , CAST(period_report_fund_active AS string)        AS period_report_fund_active
    , CAST(revenue AS decimal(38,0))                   AS revenue
    , CAST(profit AS decimal(38,0))                    AS profit
    , CAST(cost AS decimal(38,0))                      AS cost
    , CAST(properties AS decimal(38,0))                AS properties
    , CAST(period_report_finance AS string)            AS period_report_finance
    , CAST(capital_qtty AS decimal(38,0))              AS capital_qtty
    , CAST(invest_long AS decimal(38,0))               AS invest_long
    , CAST(invest_short AS decimal(38,0))              AS invest_short
    , CAST(period_report_tlattc AS string)             AS period_report_tlattc
    , CAST(tlattc_value AS decimal(38,5))              AS tlattc_value
FROM {{ source('source_fms', 'raw_securities_report') }}