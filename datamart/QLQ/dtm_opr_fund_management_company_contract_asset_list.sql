/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_management_company_contract_asset_list
* Program name: Dtm Opr Fund Management Company Contract Asset List
* Created by:
* Created date: 2026-11-11
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude				Sửa bảng rỗng: mã chỉ tiêu ở mẫu DMĐT là nhãn tĩnh (fmr_sheet.label_nm cột 2), không nằm trong cell_val.
*                                       Theo query BA Nhóm 32: mã = nhãn mẫu ưu tiên, fallback giá trị nộp cột 2; dòng sinh từ
*                                       (bản nộp × table_idx) × dòng mẫu, giữ dòng khi không có giá trị (asset_market_val_amt NULL)
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
        AND fmr_sheet_nm = '@QLDMDT'
),

fund_management_report AS (
    SELECT
        fmr_id,
        version_nbr
    FROM {{ ref('atm_fund_management_report') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_TEMP'
        AND lower(fmr_nm) LIKE '%danh mục đầu tư%'
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

-- Mọi ô sheet @QLDMDT của biểu mẫu danh mục đầu tư, kèm vị trí ô (row_index, column_index) và phiên bản mẫu
sheet_cell AS (
    SELECT
        fmr_value.fmr_submission_code,
        fmr_value.table_idx,
        fmr_value.fmr_sheet_code,
        fmr_sheet.row_index,
        fmr_sheet.column_index,
        fmr_value.investment_fund_id,
        fmr_value.investment_fund_code,
        fmr_value.fmc_id,
        fmr_value.fmc_code,
        fmr_value.record_tp,
        fmr_value.period_tp_code,
        fmr_value.period_val,
        fmr_value.rpt_year,
        fund_management_report.version_nbr,
        fmr_value.cell_val,
        fmr_value.src_stm_code
    FROM fmr_value
    INNER JOIN fmr_sheet
        ON fmr_sheet.fmr_sheet_code = fmr_value.fmr_sheet_code
        AND fmr_sheet.cell_id = fmr_value.cell_id
    INNER JOIN fund_management_report
        ON fund_management_report.fmr_id = fmr_sheet.fmr_id
    WHERE fmr_value.table_idx IS NOT NULL
),

-- Khung hợp đồng: mỗi (bản nộp, table_idx, sheet) có ô trên sheet @QLDMDT — tương ứng tập dc trong query BA
contract_key AS (
    SELECT
        fmr_submission_code,
        table_idx,
        fmr_sheet_code,
        MAX(investment_fund_id)     AS investment_fund_id,
        MAX(investment_fund_code)   AS investment_fund_code,
        MAX(fmc_id)                 AS fmc_id,
        MAX(fmc_code)               AS fmc_code,
        MAX(record_tp)              AS record_tp,
        MAX(period_tp_code)         AS period_tp_code,
        MAX(period_val)             AS period_val,
        MAX(rpt_year)               AS rpt_year,
        MAX(version_nbr)            AS version_nbr,
        MAX(src_stm_code)           AS src_stm_code
    FROM sheet_cell
    GROUP BY fmr_submission_code, table_idx, fmr_sheet_code
),

-- Nhãn tĩnh cột 2 ("Mã chỉ tiêu") của mẫu — mã nằm ở đây, không có trong RPT_VALUES (BA: hr)
template_code_row AS (
    SELECT
        fmr_sheet_code,
        row_index,
        MAX(nullif(trim(label_nm), ''))   AS label_code
    FROM fmr_sheet
    WHERE column_index = 2
    GROUP BY fmr_sheet_code, row_index
),

-- Giá trị nộp cột 2 — chỉ dùng khi dòng mẫu không có nhãn (BA: hc)
submitted_code AS (
    SELECT
        fmr_submission_code,
        table_idx,
        fmr_sheet_code,
        row_index,
        MAX(trim(cell_val))   AS cell_code
    FROM sheet_cell
    WHERE column_index = 2
    GROUP BY fmr_submission_code, table_idx, fmr_sheet_code, row_index
),

-- Dòng tài sản: mã chỉ tiêu (nhãn mẫu ưu tiên, fallback giá trị nộp) thuộc danh sách mã BA STT 32 (niêm yết) / STT 33 (chưa niêm yết).
-- Sinh dòng cho mọi hợp đồng × dòng mẫu, kể cả hợp đồng không khai giá trị (giống BA hr × dc LEFT JOIN hc)
asset_code AS (
    SELECT
        contract_key.fmr_submission_code,
        contract_key.table_idx,
        contract_key.fmr_sheet_code,
        template_code_row.row_index,
        COALESCE(template_code_row.label_code, submitted_code.cell_code)   AS asset_indicator_code,
        contract_key.investment_fund_id,
        contract_key.investment_fund_code,
        contract_key.fmc_id,
        contract_key.fmc_code,
        contract_key.record_tp,
        contract_key.period_tp_code,
        contract_key.period_val,
        contract_key.rpt_year,
        contract_key.version_nbr,
        contract_key.src_stm_code
    FROM contract_key
    INNER JOIN template_code_row
        ON template_code_row.fmr_sheet_code = contract_key.fmr_sheet_code
    LEFT JOIN submitted_code
        ON submitted_code.fmr_submission_code = contract_key.fmr_submission_code
        AND submitted_code.table_idx = contract_key.table_idx
        AND submitted_code.fmr_sheet_code = contract_key.fmr_sheet_code
        AND submitted_code.row_index = template_code_row.row_index
    WHERE COALESCE(template_code_row.label_code, submitted_code.cell_code)
        IN ('202001','202002','202003','202004','202005','201205',
            '202006','202007','202008','202009','180311')
),

-- Giá trị thị trường: ô cột 5 trên cùng dòng mẫu, cùng bản nộp/table_idx/sheet
asset_value AS (
    SELECT
        fmr_submission_code,
        table_idx,
        fmr_sheet_code,
        row_index,
        MAX(try_cast(regexp_replace(CAST(cell_val AS string), '%', '') AS decimal(38,8)))   AS asset_market_val_amt
    FROM sheet_cell
    WHERE column_index = 5
    GROUP BY fmr_submission_code, table_idx, fmr_sheet_code, row_index
)

SELECT
    CAST(asset_code.fmr_submission_code AS string)                                        AS fmr_submission_code,
    CAST(asset_code.table_idx AS int)                                                     AS table_idx,
    CAST(asset_code.asset_indicator_code AS string)                                       AS asset_indicator_code,
    CAST(asset_code.investment_fund_code AS string)                                       AS investment_fund_code,
    CAST(COALESCE(asset_code.fmc_id, investment_fund.fmc_id) AS string)                   AS fmc_id,
    CAST(COALESCE(asset_code.fmc_code, investment_fund.fmc_code) AS string)               AS fmc_code,
    CAST(asset_code.record_tp AS string)                                                  AS record_tp,
    CAST(asset_code.period_tp_code AS string)                                             AS period_tp_code,
    CAST(asset_code.period_val AS string)                                                 AS period_val,
    CAST(asset_code.rpt_year AS int)                                                      AS rpt_year,
    CAST(asset_code.version_nbr AS int)                                                   AS version_nbr,
    CAST(asset_value.asset_market_val_amt AS decimal(38,8))                               AS asset_market_val_amt,
    CAST(asset_code.src_stm_code AS string)                                               AS src_stm_code
FROM (
    -- Khử trùng theo PK (bản nộp, table_idx, mã chỉ tiêu): lấy 1 dòng mẫu/mã (MAX row_index) để PK scd4a duy nhất
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY fmr_submission_code, table_idx, asset_indicator_code
        ORDER BY row_index DESC
    ) AS rn
    FROM asset_code
) asset_code
LEFT JOIN investment_fund
    ON investment_fund.investment_fund_id = asset_code.investment_fund_id
LEFT JOIN asset_value
    ON asset_value.fmr_submission_code = asset_code.fmr_submission_code
    AND asset_value.table_idx = asset_code.table_idx
    AND asset_value.fmr_sheet_code = asset_code.fmr_sheet_code
    AND asset_value.row_index = asset_code.row_index
WHERE asset_code.rn = 1
