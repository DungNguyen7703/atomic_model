/*
*--------------------------------------------------------------------*
* Program code: dtm_dynamic_report_structure_dim
* Program name: Dtm Dynamic Report Structure Dimension
* Created by: claude (sync)
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		claude (sync)		Tạo mới theo LLD DTM_QLQ_dynamic_report_structure_dim_FMS_ITEM_LIST.csv
*                                       (scd4a, PK = dr_structure_id direct từ Atomic dr_structure — SCD2, đọc dòng đang hiệu lực).
*--------------------------------------------------------------------*
*/

WITH dr_structure AS (
    SELECT
        dr_structure_id,
        dr_structure_code,
        rpt_code,
        rpt_nm,
        sheet_nm,
        column_path,
        row_path,
        cell_id,
        row_index,
        column_index,
        legal_basis,
        label_column_ind,
        dynamic_label_row,
        src_stm_code
    FROM {{ ref('atm_dr_structure') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_ITEM_LIST'
)

SELECT
    CAST(dr_structure_id AS string)          AS dr_structure_id,
    CAST(dr_structure_code AS string)        AS dr_structure_code,
    CAST(rpt_code AS string)                 AS rpt_code,
    CAST(rpt_nm AS string)                   AS rpt_nm,
    CAST(sheet_nm AS string)                 AS sheet_nm,
    CAST(column_path AS string)              AS column_path,
    CAST(row_path AS string)                 AS structure_row_path,
    CAST(cell_id AS string)                  AS cell_id,
    CAST(row_index AS int)                   AS row_index,
    CAST(column_index AS int)                AS column_index,
    CAST(legal_basis AS string)              AS legal_basis,
    CAST(label_column_ind AS int)            AS structure_label_column_ind,
    CAST(dynamic_label_row AS string)        AS dynamic_label_row,
    CAST(src_stm_code AS string)             AS src_stm_code
FROM dr_structure
