/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_management_company_contract_list
* Program name: Dtm Opr Fund Management Company Contract List
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		claude (sync)		Đồng bộ LLD commit 4c3d0a67 (O_QLQ_68, schema-changing): thêm fmc_id = COALESCE(fmr_value.fmc_id,
*                                       investment_fund.fmc_id) — khóa lọc hợp đồng theo CTQLQ ở Nhóm 5 (= fmc_id của profile Nhóm 3);
*                                       fmc_code giữ nguyên logic (chỉ đổi mô tả LLD: không dùng làm khóa lọc). Cần DROP/CREATE lại bảng scd4a + _hstr
* 2026-11-03		claude (sync)		Đồng bộ LLD commit f2628ecf (record_tp = '2'): O_QLQ_72: bỏ lọc submitted_dt (không chặn theo ngày chạy ETL để không sót báo cáo nộp muộn); giữ record_status_code IN ('2','3','5','10') (logic-only, schema không đổi)
* 2026-11-06		claude (sync)		Đồng bộ LLD commit 1d8683aa (O_QLQ_75, schema-changing): PK dynamic_row_nbr → table_idx = CASE dynamic_val_ind 0 → dynamic_row_nbr, 1 → floor(dynamic_row_nbr/1000); ghép ô hợp đồng (customer_nm/custody_account_nbr/contract_market_val_amt) theo table_idx. Cần DROP/CREATE lại bảng scd4a + _hstr
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
        AND record_tp = '2'
        AND record_status_code IN ('2','3','5','10')
),

fmr_value AS (
    SELECT
        fmr_value.fmr_submission_code,
        -- Chỉ số bảng hợp đồng (SQL BA 2026-11-05, O_QLQ_75): ô tĩnh = dynamic_row_nbr; ô động = dynamic_row_nbr / 1000 (làm tròn xuống)
        CASE WHEN fmr_value.dynamic_val_ind = 0 THEN fmr_value.dynamic_row_nbr
             WHEN fmr_value.dynamic_val_ind = 1 THEN CAST(floor(fmr_value.dynamic_row_nbr / 1000) AS int)
        END AS table_idx,
        fmr_value.fmr_sheet_code,
        fmr_value.cell_id,
        fmr_value.investment_fund_id,
        fmr_value.investment_fund_code,
        fmr_value.fmc_id,
        fmr_value.fmc_code,
        fmr_submission.record_tp,
        fmr_submission.period_tp_code,
        fmr_submission.period_val,
        fmr_submission.rpt_year,
        fmr_value.cell_val,
        fmr_value.src_stm_code
    FROM {{ ref('atm_fmr_value') }} fmr_value
    INNER JOIN fmr_submission
        ON fmr_submission.fmr_submission_id = fmr_value.fmr_submission_id
        AND fmr_value.ds_rcrd_st = 'ACTIVE'
        AND fmr_value.src_stm_code = 'FMS_RPT_VALUES'
),

fmr_sheet AS (
    SELECT DISTINCT
        fmr_sheet_code,
        cell_id,
        fmr_id,
        fmr_sheet_nm,
        row_index,
        column_index,
        label_nm
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

investment_fund AS (
    SELECT
        investment_fund_id,
        fmc_id,
        fmc_code
    FROM {{ ref('atm_investment_fund') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

-- Nhãn tĩnh của mẫu (DATA_LABEL -> label_nm): ô nhãn không có giá trị trong RPT_VALUES nên không có ở rpt_cell
-- (BA: CASE WHEN nhãn mẫu IS NOT NULL THEN nhãn mẫu ELSE giá trị nộp)
template_row_label AS (
    SELECT
        fmr_sheet_code,
        row_index,
        MAX(CASE WHEN column_index = 1 AND lower(label_nm) LIKE '%tên khách hàng%' THEN 1 ELSE 0 END) AS customer_label_ind,
        MAX(CASE WHEN column_index = 1 AND lower(label_nm) LIKE '%tk lưu ký%' THEN 1 ELSE 0 END)      AS custody_account_label_ind,
        MAX(CASE WHEN column_index = 2 AND trim(label_nm) = '180317' THEN 1 ELSE 0 END)               AS market_val_label_ind
    FROM fmr_sheet
    WHERE fmr_sheet_nm = '@QLDMDT'
    GROUP BY fmr_sheet_code, row_index
),

-- Ô thuộc sheet @QLDMDT của biểu mẫu danh mục đầu tư, bản nộp của CTQLQ (record_tp = 2, lọc tại CTE fmr_submission)
contract_value AS (
    SELECT
        fmr_value.fmr_submission_code,
        fmr_value.table_idx,
        fmr_value.fmr_sheet_code,
        fmr_value.investment_fund_id,
        fmr_value.investment_fund_code,
        fmr_value.fmc_id,
        fmr_value.fmc_code,
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
    -- Neo hợp đồng = ô giá trị trên dòng mẫu "Tên khách hàng": dòng động lồng (danh mục CK, dynamic_row_nbr 1000, 2000...)
    -- không phải hợp đồng, nếu không neo sẽ sinh dòng NULL customer_nm/custody_account_nbr
    INNER JOIN template_row_label
        ON template_row_label.fmr_sheet_code = fmr_sheet.fmr_sheet_code
        AND template_row_label.row_index = fmr_sheet.row_index
        AND template_row_label.customer_label_ind = 1
    WHERE fmr_value.table_idx IS NOT NULL
        AND fmr_sheet.fmr_sheet_nm = '@QLDMDT'
        AND lower(fund_management_report.fmr_nm) LIKE '%danh mục đầu tư%'
),

contract_key AS (
    SELECT DISTINCT
        fmr_submission_code,
        table_idx,
        fmr_sheet_code
    FROM contract_value
),

-- Mọi ô cùng bản nộp/dòng động/sheet với hợp đồng, kèm vị trí ô trong mẫu (row_index, column_index)
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
    LEFT SEMI JOIN contract_key
        ON contract_key.fmr_submission_code = fmr_value.fmr_submission_code
        AND contract_key.table_idx = fmr_value.table_idx
        AND contract_key.fmr_sheet_code = fmr_value.fmr_sheet_code
),

-- Cờ nhãn theo dòng mẫu: cột "Loại" (column_index 1) / cột "Mã chỉ tiêu" (column_index 2)
row_label AS (
    SELECT
        fmr_submission_code,
        table_idx,
        fmr_sheet_code,
        row_index,
        MAX(CASE WHEN column_index = 1 AND lower(cell_val) LIKE '%tên khách hàng%' THEN 1 ELSE 0 END) AS customer_label_ind,
        MAX(CASE WHEN column_index = 1 AND lower(cell_val) LIKE '%tk lưu ký%' THEN 1 ELSE 0 END)      AS custody_account_label_ind,
        MAX(CASE WHEN column_index = 2 AND cell_val = '180317' THEN 1 ELSE 0 END)                    AS market_val_label_ind
    FROM rpt_cell
    GROUP BY fmr_submission_code, table_idx, fmr_sheet_code, row_index
),

contract_pivot AS (
    SELECT
        rpt_cell.fmr_submission_code,
        rpt_cell.table_idx,
        rpt_cell.fmr_sheet_code,
        MAX(CASE WHEN rpt_cell.column_index = 2
                      AND (row_label.customer_label_ind = 1 OR template_row_label.customer_label_ind = 1)
                 THEN nullif(trim(regexp_replace(rpt_cell.cell_val, '^[\\s:：]+', '')), '') END)  AS customer_nm,
        MAX(CASE WHEN rpt_cell.column_index = 2
                      AND (row_label.custody_account_label_ind = 1 OR template_row_label.custody_account_label_ind = 1)
                 THEN nullif(trim(regexp_replace(rpt_cell.cell_val, '^[\\s:：]+', '')), '') END)  AS custody_account_nbr,
        MAX(CASE WHEN rpt_cell.column_index = 5
                      AND (row_label.market_val_label_ind = 1 OR template_row_label.market_val_label_ind = 1)
                 THEN try_cast(regexp_replace(CAST(rpt_cell.cell_val AS string), '%', '') AS decimal(38,8)) END) AS contract_market_val_amt
    FROM rpt_cell
    INNER JOIN row_label
        ON row_label.fmr_submission_code = rpt_cell.fmr_submission_code
        AND row_label.table_idx = rpt_cell.table_idx
        AND row_label.fmr_sheet_code = rpt_cell.fmr_sheet_code
        AND row_label.row_index = rpt_cell.row_index
    LEFT JOIN template_row_label
        ON template_row_label.fmr_sheet_code = rpt_cell.fmr_sheet_code
        AND template_row_label.row_index = rpt_cell.row_index
    GROUP BY rpt_cell.fmr_submission_code, rpt_cell.table_idx, rpt_cell.fmr_sheet_code
)

SELECT DISTINCT
    CAST(contract_value.fmr_submission_code AS string)                                    AS fmr_submission_code,
    CAST(contract_value.table_idx AS int)                                                 AS table_idx,
    CAST(contract_value.investment_fund_code AS string)                                   AS investment_fund_code,
    CAST(COALESCE(contract_value.fmc_id, investment_fund.fmc_id) AS string)               AS fmc_id,
    CAST(COALESCE(contract_value.fmc_code, investment_fund.fmc_code) AS string)           AS fmc_code,
    CAST(contract_value.record_tp AS string)                                              AS record_tp,
    CAST(contract_value.period_tp_code AS string)                                         AS period_tp_code,
    CAST(contract_value.period_val AS string)                                             AS period_val,
    CAST(contract_value.rpt_year AS int)                                                  AS rpt_year,
    CAST(contract_value.version_nbr AS int)                                               AS version_nbr,
    CAST(contract_pivot.customer_nm AS string)                                            AS customer_nm,
    CAST(contract_pivot.custody_account_nbr AS string)                                    AS custody_account_nbr,
    CAST(contract_pivot.contract_market_val_amt AS decimal(38,8))                         AS contract_market_val_amt,
    CAST(contract_value.src_stm_code AS string)                                           AS src_stm_code
FROM contract_value
LEFT JOIN investment_fund
    ON investment_fund.investment_fund_id = contract_value.investment_fund_id
LEFT JOIN contract_pivot
    ON contract_pivot.fmr_submission_code = contract_value.fmr_submission_code
    AND contract_pivot.table_idx = contract_value.table_idx
    AND contract_pivot.fmr_sheet_code = contract_value.fmr_sheet_code
