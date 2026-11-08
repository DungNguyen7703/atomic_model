/*
*--------------------------------------------------------------------*
* Program code: ods_fms_sheet
* Program name: ODS FMS.SHEET
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khởi tạo — nguồn cho Atomic FMS (sync LLD Atomic FMS UAT 20261006)
* 2026-10-12		claude				Parse CELLS_META, DATA_LABEL, MERGE_CELLS — grain 1 cell/1 bản ghi, bỏ 3 cột gốc
* 2026-10-14		claude				cell_id: chuẩn hoá uid (uuid chữ thường có gạch) về dạng HEX của RAW(16) (chữ hoa, bỏ '-')
*                                       để khớp RPT_VALUES.TGT_ID (stg HEX(tgt_id))
*--------------------------------------------------------------------*
*/

WITH stg AS (
    SELECT
        id,
        date_created,
        created_by,
        date_modified,
        modify_by,
        rpt_id,
        item_name,
        sheet_index,
        record_status,
        description,
        investment_portfolio,
        cells_meta,
        data_label,
        merge_cells,
        row_heights,
        col_widths,
        code,
        is_admin_report
    FROM {{ ref('stg_fms_sheet') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND record_status = 1
),

-- DATA_LABEL: mảng 2 chiều [row][col] phủ toàn bộ grid của sheet -> làm base, mỗi phần tử = 1 cell
cells AS (
    SELECT
        stg.id,
        r.row_index,
        c.column_index,
        c.label_nm
    FROM stg
    LATERAL VIEW OUTER posexplode(from_json(stg.data_label, 'array<array<string>>')) r AS row_index, row_labels
    LATERAL VIEW OUTER posexplode(r.row_labels) c AS column_index, label_nm
),

-- CELLS_META: chỉ lấy row, col, uid; nguồn có phần tử null và trùng (row, col) -> lọc null + gộp
cells_meta AS (
    SELECT
        stg.id,
        cm.row      AS row_index,
        cm.col      AS column_index,
        MAX(upper(replace(cm.uid, '-', ''))) AS cell_id
    FROM stg
    LATERAL VIEW explode(from_json(stg.cells_meta, 'array<struct<row:int,col:int,uid:string>>')) t AS cm
    WHERE cm IS NOT NULL
    GROUP BY 
        stg.id, 
        cm.row, 
        cm.col

),

-- MERGE_CELLS: chỉ gán span cho ô gốc (góc trên-trái) của vùng merge còn hiệu lực
merge_cells AS (

    SELECT
        stg.id,
        mc.row          AS row_index,
        mc.col          AS column_index,
        MAX(mc.rowspan) AS row_span,
        MAX(mc.colspan) AS column_span
    FROM stg
    LATERAL VIEW explode(from_json(stg.merge_cells, 'array<struct<row:int,col:int,rowspan:int,colspan:int,removed:boolean>>')) t AS mc
    WHERE mc IS NOT NULL
        AND COALESCE(mc.removed, false) = false
    GROUP BY 
        stg.id, 
        mc.row, 
        mc.col

),

-- Bung mỗi vùng merge ra toàn bộ ô nó phủ: ô gốc giữ span, ô bị gộp (che) -> span NULL
merge_area AS (
    SELECT
        merge_cells.id, 
        merge_cells.row_index + r.row_offset       AS row_index,
        merge_cells.column_index + c.column_offset AS column_index,
        MAX(CASE WHEN r.row_offset = 0 AND c.column_offset = 0 THEN merge_cells.row_span END)    AS row_span,
        MAX(CASE WHEN r.row_offset = 0 AND c.column_offset = 0 THEN merge_cells.column_span END) AS column_span
    FROM merge_cells
    LATERAL VIEW explode(sequence(0, GREATEST(COALESCE(merge_cells.row_span, 1), 1) - 1)) r AS row_offset
    LATERAL VIEW explode(sequence(0, GREATEST(COALESCE(merge_cells.column_span, 1), 1) - 1)) c AS column_offset
    GROUP BY
        merge_cells.id,
        merge_cells.row_index + r.row_offset,
        merge_cells.column_index + c.column_offset
)

SELECT
    stg.id,
    stg.date_created,
    stg.created_by,
    stg.date_modified,
    stg.modify_by,
    stg.rpt_id,
    stg.item_name,
    stg.sheet_index,
    stg.record_status,
    stg.description,
    stg.investment_portfolio,
    cells.row_index,
    cells.column_index,
    cells_meta.cell_id,
    cells.label_nm,
    CASE WHEN merge_area.id IS NULL THEN 1 ELSE merge_area.row_span END    AS row_span,
    CASE WHEN merge_area.id IS NULL THEN 1 ELSE merge_area.column_span END AS column_span,
    stg.row_heights,
    stg.col_widths,
    stg.code,
    stg.is_admin_report
FROM stg
INNER JOIN cells
    ON cells.id = stg.id
LEFT JOIN cells_meta
    ON cells_meta.id = cells.id
    AND cells_meta.row_index = cells.row_index
    AND cells_meta.column_index = cells.column_index
LEFT JOIN merge_area
    ON merge_area.id = cells.id
    AND merge_area.row_index = cells.row_index
    AND merge_area.column_index = cells.column_index
