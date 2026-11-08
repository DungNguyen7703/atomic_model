/*
*--------------------------------------------------------------------*
* Program code: stg_fms_inves_report
* Program name: Staging FMS.INVES_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , HEX(inves_acc_id)                  AS inves_acc_id
    , HEX(inves_id)                      AS inves_id
    , CAST(excution_date AS timestamp)   AS excution_date
    , CAST(period_type AS decimal(18,2)) AS period_type
    , CAST(ad_scale AS decimal(38,0))    AS ad_scale
    , CAST(act_scale AS decimal(38,0))   AS act_scale
    , CAST(list_value AS decimal(38,0))  AS list_value
    , CAST(manager_fee AS decimal(38,0)) AS manager_fee
    , CAST(period_report AS string)      AS period_report
FROM {{ source('source_fms', 'raw_inves_report') }}