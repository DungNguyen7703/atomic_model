/*
*--------------------------------------------------------------------*
* Program code: stg_fms_sheet
* Program name: Staging FMS.SHEET
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                             AS id
    , CAST(date_created AS date)        AS date_created
    , CAST(created_by AS string)        AS created_by
    , CAST(date_modified AS date)       AS date_modified
    , CAST(modify_by AS string)         AS modify_by
    , HEX(rpt_id)                       AS rpt_id
    , CAST(item_name AS string)         AS item_name
    , CAST(sheet_index AS bigint)       AS sheet_index
    , CAST(record_status AS int)        AS record_status
    , CAST(description AS string)       AS description
    , CAST(investment_portfolio AS int) AS investment_portfolio
    , CAST(cells_meta AS string)              AS cells_meta   
    , CAST(data_label AS string)              AS data_label   
    , CAST(merge_cells AS string)              AS merge_cells  
    , CAST(row_heights AS string)              AS row_heights  
    , CAST(col_widths AS string)              AS col_widths   
    , CAST(code AS string)              AS code
    , CAST(is_admin_report AS int )     AS is_admin_report
FROM {{ source('source_fms', 'raw_sheet') }}