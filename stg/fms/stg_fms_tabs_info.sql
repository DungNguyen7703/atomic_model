/*
*--------------------------------------------------------------------*
* Program code: stg_fms_tabs_info
* Program name: Staging FMS.TABS_INFO
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
    , HEX(tp_out_id)                AS tp_out_id
    , CAST(tab_groups AS bigint)    AS tab_groups
    , CAST(tab_code AS bigint)      AS tab_code
    , CAST(item_name AS string)     AS item_name
    , CAST(description AS string)   AS description
    , CAST(period_type AS bigint)   AS period_type
    , CAST(cell_meta AS string)     AS cell_meta
    , CAST(tab_column AS bigint)    AS tab_column
    , CAST(report_input_tab AS int) AS report_input_tab
    , HEX(rpt_id)                   AS rpt_id
    , CAST(record_status AS int)    AS record_status
    , CAST(tab_row AS bigint)       AS tab_row
FROM {{ source('source_fms', 'raw_tabs_info') }}