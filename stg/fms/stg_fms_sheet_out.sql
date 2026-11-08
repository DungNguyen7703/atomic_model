/*
*--------------------------------------------------------------------*
* Program code: stg_fms_sheet_out
* Program name: Staging FMS.SHEET_OUT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                       AS id
    , CAST(date_created AS date)  AS date_created
    , CAST(created_by AS string)  AS created_by
    , CAST(date_modified AS date) AS date_modified
    , CAST(modify_by AS string)   AS modify_by
    , HEX(tp_out_id)              AS tp_out_id
    , CAST(item_name AS string)   AS item_name
    , CAST(sheet_index AS bigint) AS sheet_index
    , CAST(record_status AS int)  AS record_status
    , CAST(description AS string) AS description
    , CAST(cells_meta AS string)  AS cells_meta
    , CAST(row_heights AS string) AS row_heights
    , CAST(data_label AS string)  AS data_label
    , CAST(merge_cells AS string) AS merge_cells
    , CAST(col_widths AS string)  AS col_widths
    , CAST(code AS string)        AS code
FROM {{ source('source_fms', 'raw_sheet_out') }}