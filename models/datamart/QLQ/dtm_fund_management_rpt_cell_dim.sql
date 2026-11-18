/*
*--------------------------------------------------------------------*
* Program code: dtm_fund_management_rpt_cell_dim
* Program name: Dtm Fund Management Report Cell Dimension
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		claude (sync)		Đồng bộ LLD commit c4746d2d (O_QLQ_69/70): row_indicator_code nhận cột tiêu đề 'Mã chỉ tiêu' HOẶC 'Mã số'
*                                       (sheet BCTC BangCanDoiKeToan/BCKetQuaHoatDongKinhDoanh); row_label/column_label bỏ nhãn chỉ gồm dấu chấm
*                                       ('...', '…') khỏi phép nối (REGEXP_LIKE LLD -> RLIKE) (logic-only, schema không đổi)
*--------------------------------------------------------------------*
*/

WITH fmr_sheet AS (
    SELECT DISTINCT
        fmr_sheet_code,
        cell_id,
        fmr_id,
        fmr_code,
        fmr_sheet_nm,
        sheet_short_code,
        sheet_index,
        investment_portfolio_ind,
        row_index,
        column_index,
        row_span,
        column_span,
        label_nm,
        src_stm_code
    FROM {{ ref('atm_fmr_sheet') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SHEET'
        -- Bỏ ô trống phần lưới thừa của DATA_LABEL: chỉ giữ ô nhập (có cell_id) và ô nhãn
        AND (cell_id IS NOT NULL OR NULLIF(TRIM(label_nm), '') IS NOT NULL)
),

fund_management_report AS (
    SELECT
        fmr_id,
        fmr_nm,
        fmr_tp_code,
        rpt_short_code,
        rpt_group_code,
        stm_object_tp_code,
        cl_fms_fund_tp_code,
        version_nbr,
        legal_basis
    FROM {{ ref('atm_fund_management_report') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_TEMP'
),

header_row AS (
    SELECT
        fmr_sheet_code,
        MIN(row_index) AS header_row_index
    FROM fmr_sheet
    GROUP BY fmr_sheet_code
),

header_col AS (
    -- STT: mọi hàng của sheet (O_QLQ_57); Mã chỉ tiêu/Chỉ tiêu: chỉ hàng header = MIN(row_index)
    SELECT
        h.fmr_sheet_code,
        MIN(CASE WHEN h.label_nm = 'STT' 
                THEN h.column_index END) AS stt_column_index,
        MIN(CASE WHEN h.label_nm IN ('Mã chỉ tiêu', 'Mã số') AND h.row_index = hr.header_row_index 
                THEN h.column_index END) AS indicator_code_column_index,
        MIN(CASE WHEN h.label_nm = 'Chỉ tiêu' AND h.row_index = hr.header_row_index 
                THEN h.column_index END) AS indicator_nm_column_index
    FROM fmr_sheet h
    INNER JOIN header_row hr
        ON hr.fmr_sheet_code = h.fmr_sheet_code
    GROUP BY h.fmr_sheet_code
),

row_key AS (
    SELECT
        r.fmr_sheet_code,
        r.row_index,
        MAX(CASE WHEN r.column_index = hc.stt_column_index 
                THEN r.label_nm END) AS row_stt_code,
        MAX(CASE WHEN r.column_index = hc.indicator_code_column_index 
                THEN r.label_nm END) AS row_indicator_code,
        MAX(CASE WHEN r.column_index = hc.indicator_nm_column_index 
                THEN r.label_nm END) AS row_indicator_nm
    FROM fmr_sheet r
    INNER JOIN header_col hc
        ON hc.fmr_sheet_code = r.fmr_sheet_code
    GROUP BY r.fmr_sheet_code, r.row_index
),

row_label AS (
    -- Nhãn dòng: các ô bên trái (column_index nhỏ hơn) mà vùng row_span phủ hàng của ô hiện tại
    SELECT
        cur.fmr_sheet_code,
        cur.cell_id,
        array_join(
            transform(
                array_sort(collect_list(named_struct('c', lbl.column_index, 'r', lbl.row_index, 'l', lbl.label_nm))),
                x -> x.l
            ),
            ' >> '
        ) AS row_label_nm
    FROM fmr_sheet cur
    INNER JOIN fmr_sheet lbl
        ON lbl.fmr_sheet_code = cur.fmr_sheet_code
        AND NULLIF(TRIM(lbl.label_nm), '') IS NOT NULL
        AND NOT (TRIM(lbl.label_nm) RLIKE '^[.…]+$')
        AND lbl.column_index < cur.column_index
        AND cur.row_index BETWEEN lbl.row_index AND lbl.row_index + COALESCE(lbl.row_span, 1) - 1
    WHERE cur.cell_id IS NOT NULL
    GROUP BY cur.fmr_sheet_code, cur.cell_id
),

column_label AS (
    -- Nhãn cột: các ô phía trên (row_index nhỏ hơn) mà vùng column_span phủ cột của ô hiện tại
    SELECT
        cur.fmr_sheet_code,
        cur.cell_id,
        array_join(
            transform(
                array_sort(collect_list(named_struct('r', lbl.row_index, 'c', lbl.column_index, 'l', lbl.label_nm))),
                x -> x.l
            ),
            ' >> '
        ) AS column_label_nm
    FROM fmr_sheet cur
    INNER JOIN fmr_sheet lbl
        ON lbl.fmr_sheet_code = cur.fmr_sheet_code
        AND NULLIF(TRIM(lbl.label_nm), '') IS NOT NULL
        AND NOT (TRIM(lbl.label_nm) RLIKE '^[.…]+$')
        AND lbl.row_index < cur.row_index
        AND cur.column_index BETWEEN lbl.column_index AND lbl.column_index + COALESCE(lbl.column_span, 1) - 1
    WHERE cur.cell_id IS NOT NULL
    GROUP BY cur.fmr_sheet_code, cur.cell_id
)

SELECT
    CAST({{ generate_surrogate_key_bigint('FMS_SHEET', "concat_ws('|', fmr_sheet.fmr_sheet_code, fmr_sheet.cell_id)") }} AS string) AS fund_management_rpt_cell_id,
    CAST(fmr_sheet.fmr_sheet_code AS string)                                                  AS fmr_sheet_code,
    CAST(fmr_sheet.cell_id AS string)                                                         AS cell_id,
    CAST(fmr_sheet.fmr_code AS string)                                                        AS fmr_code,
    CAST(fund_management_report.fmr_nm AS string)                                             AS fmr_nm,
    CAST(fund_management_report.fmr_tp_code AS string)                                        AS fmr_tp_code,
    CAST(fund_management_report.rpt_short_code AS string)                                     AS rpt_short_code,
    CAST(fund_management_report.rpt_group_code AS string)                                     AS rpt_group_code,
    CAST(fund_management_report.stm_object_tp_code AS string)                                 AS stm_object_tp_code,
    CAST(fund_management_report.cl_fms_fund_tp_code AS string)                                AS cl_fms_fund_tp_code,
    CAST(fund_management_report.version_nbr AS int)                                           AS version_nbr,
    CAST(fund_management_report.legal_basis AS string)                                        AS legal_basis,
    CAST(fmr_sheet.fmr_sheet_nm AS string)                                                    AS fmr_sheet_nm,
    CAST(fmr_sheet.sheet_short_code AS string)                                                AS sheet_short_code,
    CAST(fmr_sheet.sheet_index AS int)                                                        AS sheet_index,
    CAST(fmr_sheet.investment_portfolio_ind AS int)                                           AS investment_portfolio_indicator,
    CAST(fmr_sheet.row_index AS int)                                                          AS row_index,
    CAST(fmr_sheet.column_index AS int)                                                       AS column_index,
    CAST(fmr_sheet.row_span AS int)                                                           AS row_span,
    CAST(fmr_sheet.column_span AS int)                                                        AS column_span,
    CAST(fmr_sheet.label_nm AS string)                                                        AS label_nm,
    CAST(row_key.row_stt_code AS string)                                                      AS row_stt_code,
    CAST(row_key.row_indicator_code AS string)                                                AS row_indicator_code,
    CAST(row_key.row_indicator_nm AS string)                                                  AS row_indicator_nm,
    CAST(row_label.row_label_nm AS string)                                                    AS row_label_nm,
    CAST(column_label.column_label_nm AS string)                                              AS column_label_nm,
    CAST(fmr_sheet.src_stm_code AS string)                                                    AS src_stm_code
FROM fmr_sheet
LEFT JOIN fund_management_report
    ON fund_management_report.fmr_id = fmr_sheet.fmr_id
LEFT JOIN row_key
    ON row_key.fmr_sheet_code = fmr_sheet.fmr_sheet_code
    AND row_key.row_index = fmr_sheet.row_index
LEFT JOIN row_label
    ON row_label.fmr_sheet_code = fmr_sheet.fmr_sheet_code
    AND row_label.cell_id = fmr_sheet.cell_id
LEFT JOIN column_label
    ON column_label.fmr_sheet_code = fmr_sheet.fmr_sheet_code
    AND column_label.cell_id = fmr_sheet.cell_id
WHERE fmr_sheet.cell_id IS NOT NULL
