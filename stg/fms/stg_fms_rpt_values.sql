/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rpt_values
* Program name: Staging FMS.RPT_VALUES
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
    , CAST(date_created AS date)         AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS date)        AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , HEX(tgt_id)                        AS tgt_id
    , HEX(meb_id)                        AS meb_id
    , HEX(sheet_id)                      AS sheet_id
    , HEX(rpt_id)                        AS rpt_id
    , CAST(values AS string)             AS values
    , HEX(prd_id)                        AS prd_id
    , CAST(dynamic_value AS int)         AS dynamic_value
    , CAST(acc_values AS string)         AS acc_values
    , CAST(period_type AS bigint)        AS period_type
    , CAST(format_data_type AS string)   AS format_data_type
    , CAST(code AS string)               AS code
    , HEX(bkm_id)                        AS bkm_id
    , HEX(fnd_id)                        AS fnd_id
    , HEX(fr_br_id)                      AS fr_br_id
    , HEX(sec_id)                        AS sec_id
    , CAST(record_type AS decimal(38,0)) AS record_type
    , CAST(period_value AS string)       AS period_value
    , CAST(year_value AS decimal(18,2))  AS year_value
    , CAST(row_dynamic AS bigint)        AS row_dynamic
FROM {{ source('source_fms', 'raw_rpt_values') }}