/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_foreign_fund_management_organization_unit_contract_list
* Program name: Dtm Opr Foreign Fund Management Organization Unit Contract List
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-03		claude (sync)		Đồng bộ LLD commit f2628ecf (record_tp = '4'): O_QLQ_72: bỏ lọc submitted_dt (không chặn theo ngày chạy ETL để không sót báo cáo nộp muộn); giữ record_status_code IN ('2','3','5','10') (logic-only, schema không đổi)
* 2026-11-09		claude (sync)		Đồng bộ LLD commit 48c65dde (O_QLQ_82, schema-changing): PK dynamic_row_nbr → table_idx = CASE dynamic_val_ind 0 → dynamic_row_nbr, 1 → floor(dynamic_row_nbr/1000); ghép ô theo table_idx; chọn sheet @QLDMDT, bỏ lọc legal_basis 97/2020/TT; nhãn 'tk lưu ký'; dòng tổng = mã '180317' ở cột 2, giá trị ở cột 6 (column_index 5). Cần ALTER RENAME COLUMN trên bảng scd4a + _hstr
*--------------------------------------------------------------------*
*/

WITH fmr_submission AS (
    SELECT
        fmr_submission_id,
        record_tp,
        period_tp_code,
        period_val,
        rpt_year
    FROM {{ ref('atm_fmr_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_MEMBER'
        AND record_tp = '4'
        AND record_status_code IN ('2','3','5','10')
),

fmr_value AS (
    SELECT
        fmr_value.fmr_submission_code,
        -- Chỉ số bảng hợp đồng (SQL BA 2026-11-09, O_QLQ_82): ô tĩnh = dynamic_row_nbr; ô động = dynamic_row_nbr / 1000 (làm tròn xuống)
        CASE WHEN fmr_value.dynamic_val_ind = 0 THEN fmr_value.dynamic_row_nbr
             WHEN fmr_value.dynamic_val_ind = 1 THEN CAST(floor(fmr_value.dynamic_row_nbr / 1000) AS int)
        END AS table_idx,
        fmr_value.fmr_sheet_code,
        fmr_value.cell_id,
        fmr_value.foreign_fm_ou_code,
        fmr_submission.record_tp,
        fmr_submission.period_tp_code,
        fmr_submission.period_val,
        fmr_submission.rpt_year,
        fmr_value.cell_val,
        fmr_value.src_stm_code
    FROM {{ ref('atm_fmr_value') }} fmr_value
    INNER JOIN fmr_submission
        ON fmr_submission.fmr_submission_id = fmr_value.fmr_submission_id
    WHERE fmr_value.ds_rcrd_st = 'ACTIVE'
        AND fmr_value.src_stm_code = 'FMS_RPT_VALUES'
),

fmr_sheet AS (
    SELECT DISTINCT
        fmr_sheet_code,
        cell_id,
        fmr_id,
        fmr_sheet_nm,
        row_index,
        column_index
    FROM {{ ref('atm_fmr_sheet') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SHEET'
),

fund_management_report AS (
    SELECT
        fmr_id,
        fmr_nm,
        version_nbr
    FROM {{ ref('atm_fund_management_report') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_TEMP'
),

-- Ô thuộc sheet @QLDMDT của biểu mẫu danh mục đầu tư, bản nộp của chi nhánh CTQLQ nước ngoài (record_tp = 4, lọc tại CTE fmr_submission)
candidate_value AS (
    SELECT
        fmr_value.fmr_submission_code,
        fmr_value.table_idx,
        fmr_value.fmr_sheet_code,
        fmr_value.foreign_fm_ou_code,
        fmr_value.record_tp,
        fmr_value.period_tp_code,
        fmr_value.period_val,
        fmr_value.rpt_year,
        fund_management_report.version_nbr,
        fmr_value.src_stm_code
    FROM fmr_value
    INNER JOIN fmr_sheet
        ON fmr_sheet.fmr_sheet_code = fmr_value.fmr_sheet_code
        AND fmr_sheet.cell_id = fmr_value.cell_id
    INNER JOIN fund_management_report
        ON fund_management_report.fmr_id = fmr_sheet.fmr_id
    WHERE fmr_value.table_idx IS NOT NULL
        AND fmr_sheet.fmr_sheet_nm = '@QLDMDT'
        AND lower(fund_management_report.fmr_nm) LIKE '%danh mục đầu tư%'
),

candidate_key AS (
    SELECT DISTINCT
        fmr_submission_code,
        table_idx,
        fmr_sheet_code
    FROM candidate_value
),

-- Mọi ô cùng bản nộp/bảng hợp đồng/sheet với dòng ứng viên, kèm vị trí ô trong mẫu (row_index, column_index)
rpt_cell AS (
    SELECT
        fmr_value.fmr_submission_code,
        fmr_value.table_idx,
        fmr_value.fmr_sheet_code,
        fmr_sheet.row_index,
        fmr_sheet.column_index,
        fmr_value.cell_val
    FROM fmr_value
    INNER JOIN fmr_sheet
        ON fmr_sheet.fmr_sheet_code = fmr_value.fmr_sheet_code
        AND fmr_sheet.cell_id = fmr_value.cell_id
    LEFT SEMI JOIN candidate_key
        ON candidate_key.fmr_submission_code = fmr_value.fmr_submission_code
        AND candidate_key.table_idx = fmr_value.table_idx
        AND candidate_key.fmr_sheet_code = fmr_value.fmr_sheet_code
),

-- Bảng là hợp đồng khi có ô cột "Loại" (column_index 1) chứa 'tên khách hàng' (EXISTS lv/lc của LLD)
contract_key AS (
    SELECT DISTINCT
        fmr_submission_code,
        table_idx,
        fmr_sheet_code
    FROM rpt_cell
    WHERE column_index = 1
        AND lower(cell_val) LIKE '%tên khách hàng%'
),

-- Cờ nhãn theo dòng mẫu: cột "Loại" (column_index 1) cho tên khách hàng/TK lưu ký; cột "Mã chỉ tiêu" (column_index 2) cho dòng tổng '180317'
row_label AS (
    SELECT
        fmr_submission_code,
        table_idx,
        fmr_sheet_code,
        row_index,
        MAX(CASE WHEN column_index = 1 AND lower(cell_val) LIKE '%tên khách hàng%' THEN 1 ELSE 0 END)       AS customer_label_ind,
        MAX(CASE WHEN column_index = 1 AND lower(cell_val) LIKE '%tk lưu ký%' THEN 1 ELSE 0 END)     AS custody_account_label_ind,
        MAX(CASE WHEN column_index = 2 AND cell_val = '180317' THEN 1 ELSE 0 END)                           AS market_val_label_ind
    FROM rpt_cell
    GROUP BY fmr_submission_code, table_idx, fmr_sheet_code, row_index
),

contract_pivot AS (
    SELECT
        rpt_cell.fmr_submission_code,
        rpt_cell.table_idx,
        rpt_cell.fmr_sheet_code,
        MAX(CASE WHEN rpt_cell.column_index = 2 AND row_label.customer_label_ind = 1
                 THEN rpt_cell.cell_val END)                                                        AS customer_nm,
        MAX(CASE WHEN rpt_cell.column_index = 2 AND row_label.custody_account_label_ind = 1
                 THEN rpt_cell.cell_val END)                                                        AS custody_account_nbr,
        MAX(CASE WHEN rpt_cell.column_index = 5 AND row_label.market_val_label_ind = 1
                 THEN try_cast(regexp_replace(CAST(rpt_cell.cell_val AS string), '%', '') AS decimal(38,8)) END) AS contract_market_val_amt
    FROM rpt_cell
    INNER JOIN row_label
        ON row_label.fmr_submission_code = rpt_cell.fmr_submission_code
        AND row_label.table_idx = rpt_cell.table_idx
        AND row_label.fmr_sheet_code = rpt_cell.fmr_sheet_code
        AND row_label.row_index = rpt_cell.row_index
    GROUP BY rpt_cell.fmr_submission_code, rpt_cell.table_idx, rpt_cell.fmr_sheet_code
)

SELECT DISTINCT
    CAST(candidate_value.fmr_submission_code AS string)                                 AS fmr_submission_code,
    CAST(candidate_value.table_idx AS int)                                        AS table_idx,
    CAST(candidate_value.foreign_fm_ou_code AS string)                                  AS foreign_fund_management_organization_unit_code,
    CAST(candidate_value.record_tp AS string)                                           AS record_tp,
    CAST(candidate_value.period_tp_code AS string)                                      AS period_tp_code,
    CAST(candidate_value.period_val AS string)                                          AS period_val,
    CAST(candidate_value.rpt_year AS int)                                               AS rpt_year,
    CAST(candidate_value.version_nbr AS int)                                            AS version_nbr,
    CAST(contract_pivot.customer_nm AS string)                                          AS customer_nm,
    CAST(contract_pivot.custody_account_nbr AS string)                                  AS custody_account_nbr,
    CAST(contract_pivot.contract_market_val_amt AS decimal(38,8))                       AS contract_market_val_amt,
    CAST(candidate_value.src_stm_code AS string)                                        AS src_stm_code
FROM candidate_value
LEFT SEMI JOIN contract_key
    ON contract_key.fmr_submission_code = candidate_value.fmr_submission_code
    AND contract_key.table_idx = candidate_value.table_idx
    AND contract_key.fmr_sheet_code = candidate_value.fmr_sheet_code
LEFT JOIN contract_pivot
    ON contract_pivot.fmr_submission_code = candidate_value.fmr_submission_code
    AND contract_pivot.table_idx = candidate_value.table_idx
    AND contract_pivot.fmr_sheet_code = candidate_value.fmr_sheet_code
