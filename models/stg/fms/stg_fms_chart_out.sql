/*
*--------------------------------------------------------------------*
* Program code: stg_fms_chart_out
* Program name: Staging FMS.CHART_OUT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                         AS id
    , CAST(date_created AS date)    AS date_created
    , CAST(created_by AS string)    AS created_by
    , CAST(date_modified AS date)   AS date_modified
    , CAST(modify_by AS string)     AS modify_by
    , CAST(item_name AS string)     AS item_name
    , CAST(chart_type AS bigint)    AS chart_type
    , CAST(system_object AS bigint) AS system_object
    , CAST(period_type AS bigint)   AS period_type
    , CAST(cell_meta AS string)     AS cell_meta
    , HEX(tp_out_id)                AS tp_out_id
    , CAST(record_status AS int)    AS record_status
FROM {{ source('source_fms', 'raw_chart_out') }}