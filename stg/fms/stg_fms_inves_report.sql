/*
*--------------------------------------------------------------------*
* Program code: stg_fms_inves_report
* Program name: Staging FMS.INVES_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu decimal(38,0) sang bigint (4 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , HEX(inves_acc_id)                  AS inves_acc_id
    , HEX(inves_id)                      AS inves_id
    , CAST(excution_date AS timestamp)   AS excution_date
    , CAST(period_type AS decimal(18,2)) AS period_type
    , CAST(ad_scale AS bigint)           AS ad_scale
    , CAST(act_scale AS bigint)          AS act_scale
    , CAST(list_value AS bigint)         AS list_value
    , CAST(manager_fee AS bigint)        AS manager_fee
    , CAST(period_report AS string)      AS period_report
FROM {{ source('source_fms', 'raw_inves_report') }}