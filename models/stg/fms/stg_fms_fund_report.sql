/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fund_report
* Program name: Staging FMS.FUND_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu timestamp sang date (1 cot); kieu decimal(38,0) sang bigint (8 cot); kieu decimal(38,0) sang int (9 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                         AS id
    , HEX(fund_id)                                  AS fund_id
    , HEX(sec_id)                                   AS sec_id
    , CAST(excution_date AS date)                   AS excution_date
    , CAST(period_type AS decimal(18,2))            AS period_type
    , CAST(nav AS bigint)                           AS nav
    , CAST(total_property AS bigint)                AS total_property
    , CAST(total_ccq AS int)                        AS total_ccq
    , CAST(nav_ccq AS int)                          AS nav_ccq
    , CAST(period_report AS string)                 AS period_report
    , CAST(sum_val_public_stock AS bigint)          AS sum_val_public_stock
    , CAST(sum_val_private_stock AS bigint)         AS sum_val_private_stock
    , CAST(sum_val_bonds AS bigint)                 AS sum_val_bonds
    , CAST(sum_val_other_stock AS bigint)           AS sum_val_other_stock
    , CAST(sum_val_other_property AS bigint)        AS sum_val_other_property
    , CAST(sum_val_money AS bigint)                 AS sum_val_money
    , CAST(prop_public_stock AS int)                AS prop_public_stock
    , CAST(prop_private_stock AS int)               AS prop_private_stock
    , CAST(prop_bonds AS int)                       AS prop_bonds
    , CAST(prop_other_stock AS int)                 AS prop_other_stock
    , CAST(prop_other_property AS int)              AS prop_other_property
    , CAST(prop_money AS int)                       AS prop_money
    , CAST(period_report_list AS string)            AS period_report_list
    , CAST(number_cer_funds AS int)                 AS number_cer_funds
    , CAST(period_report_num_cer AS string)         AS period_report_num_cer
FROM {{ source('source_fms', 'raw_fund_report') }}