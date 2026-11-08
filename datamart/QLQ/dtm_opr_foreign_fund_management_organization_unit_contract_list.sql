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
        fmr_value.dynamic_row_nbr,
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
        legal_basis,
        version_nbr
    FROM {{ ref('atm_fund_management_report') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_TEMP'
),

-- Ô thuộc biểu mẫu danh mục đầu tư theo TT 97/2020, bản nộp của chi nhánh CTQLQ nước ngoài (record_tp = 4, lọc tại CTE fmr_submission)
candidate_value AS (
    SELECT
        fmr_value.fmr_submission_code,
        fmr_value.dynamic_row_nbr,
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
    WHERE fmr_value.dynamic_row_nbr IS NOT NULL
        AND lower(fund_management_report.fmr_nm) LIKE '%danh mục đầu tư%'
        AND fund_management_report.legal_basis LIKE '%97/2020/TT%'
),

candidate_key AS (
    SELECT DISTINCT
        fmr_submission_code,
        dynamic_row_nbr,
        fmr_sheet_code
    FROM candidate_value
),

-- Mọi ô cùng bản nộp/dòng động/sheet với dòng ứng viên, kèm vị trí ô trong mẫu (row_index, column_index)
rpt_cell AS (
    SELECT
        fmr_value.fmr_submission_code,
        fmr_value.dynamic_row_nbr,
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
        AND candidate_key.dynamic_row_nbr = fmr_value.dynamic_row_nbr
        AND candidate_key.fmr_sheet_code = fmr_value.fmr_sheet_code
),

-- Dòng động là hợp đồng khi có ô cột "Loại" (column_index 1) chứa 'tên khách hàng' (EXISTS lv/lc của LLD)
contract_key AS (
    SELECT DISTINCT
        fmr_submission_code,
        dynamic_row_nbr,
        fmr_sheet_code
    FROM rpt_cell
    WHERE column_index = 1
        AND lower(cell_val) LIKE '%tên khách hàng%'
),

-- Cờ nhãn theo dòng mẫu, đều nằm ở cột "Loại" (column_index 1)
row_label AS (
    SELECT
        fmr_submission_code,
        dynamic_row_nbr,
        fmr_sheet_code,
        row_index,
        MAX(CASE WHEN column_index = 1 AND lower(cell_val) LIKE '%tên khách hàng%' THEN 1 ELSE 0 END)       AS customer_label_ind,
        MAX(CASE WHEN column_index = 1 AND lower(cell_val) LIKE '%tài khoản lưu ký%' THEN 1 ELSE 0 END)     AS custody_account_label_ind,
        MAX(CASE WHEN column_index = 1 AND lower(cell_val) LIKE '%tổng danh mục đầu tư%' THEN 1 ELSE 0 END) AS market_val_label_ind
    FROM rpt_cell
    GROUP BY fmr_submission_code, dynamic_row_nbr, fmr_sheet_code, row_index
),

contract_pivot AS (
    SELECT
        rpt_cell.fmr_submission_code,
        rpt_cell.dynamic_row_nbr,
        rpt_cell.fmr_sheet_code,
        MAX(CASE WHEN rpt_cell.column_index = 2 AND row_label.customer_label_ind = 1
                 THEN rpt_cell.cell_val END)                                                        AS customer_nm,
        MAX(CASE WHEN rpt_cell.column_index = 2 AND row_label.custody_account_label_ind = 1
                 THEN rpt_cell.cell_val END)                                                        AS custody_account_nbr,
        MAX(CASE WHEN rpt_cell.column_index = 4 AND row_label.market_val_label_ind = 1
                 THEN try_cast(regexp_replace(CAST(rpt_cell.cell_val AS string), '%', '') AS decimal(38,8)) END) AS contract_market_val_amt
    FROM rpt_cell
    INNER JOIN row_label
        ON row_label.fmr_submission_code = rpt_cell.fmr_submission_code
        AND row_label.dynamic_row_nbr = rpt_cell.dynamic_row_nbr
        AND row_label.fmr_sheet_code = rpt_cell.fmr_sheet_code
        AND row_label.row_index = rpt_cell.row_index
    GROUP BY rpt_cell.fmr_submission_code, rpt_cell.dynamic_row_nbr, rpt_cell.fmr_sheet_code
)

SELECT DISTINCT
    CAST(candidate_value.fmr_submission_code AS string)                                 AS fmr_submission_code,
    CAST(candidate_value.dynamic_row_nbr AS int)                                        AS dynamic_row_nbr,
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
    AND contract_key.dynamic_row_nbr = candidate_value.dynamic_row_nbr
    AND contract_key.fmr_sheet_code = candidate_value.fmr_sheet_code
LEFT JOIN contract_pivot
    ON contract_pivot.fmr_submission_code = candidate_value.fmr_submission_code
    AND contract_pivot.dynamic_row_nbr = candidate_value.dynamic_row_nbr
    AND contract_pivot.fmr_sheet_code = candidate_value.fmr_sheet_code
