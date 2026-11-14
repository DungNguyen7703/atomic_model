/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_fund_management_rpt_cell_val
* Program name: Dtm Fact Fund Management Report Cell Value
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		claude (sync)		Đồng bộ LLD commit ed71223d (O_QLQ_64, schema-changing): thêm fmc_id = fmr_value.fmc_id
*                                       (hash SEC_ID = SECURITIES.ID) — khóa nối opr_fund_management_company_profile.fmc_id
* 2026-11-11		claude (sync)		Đồng bộ LLD commit 56eb71c6 (O_QLQ_87, SCHEMA-CHANGING): thêm row_indicator_val_code (string) = giá trị ô cột mã
*                                       (column_index = 2) cùng dòng biểu mẫu/hàng động/bản nộp; subquery tương quan LLD -> CTE row_indicator
*                                       GROUP BY + LEFT JOIN. row_index/column_index lấy từ dtm_fund_management_rpt_cell_dim (cùng giá trị atm_fmr_sheet)
*--------------------------------------------------------------------*
*/

WITH fmr_value AS (
    SELECT
        fmr_val_code,
        fmr_submission_id,
        fmr_submission_code,
        fmr_sheet_code,
        cell_id,
        investment_fund_id,
        investment_fund_code,
        fmc_id,
        fmc_code,
        foreign_fm_ou_code,
        dynamic_val_ind,
        dynamic_row_nbr,
        cell_val,
        src_stm_code
    FROM {{ ref('atm_fmr_value') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_VALUES'
),

fmr_submission AS (
    SELECT
        fmr_submission_id,
        securities_distribution_agent_code,
        fmr_period_code,
        period_tp_code,
        period_val,
        rpt_year,
        record_tp,
        submitted_dt
    FROM {{ ref('atm_fmr_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_MEMBER'
        AND record_status_code IN ('2','3','5','10')
        -- AND submitted_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

fmr_period AS (
    SELECT
        fmr_period_code,
        period_tp_code
    FROM {{ ref('atm_fmr_period') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_PERIOD'
),

fund_management_rpt_cell AS (
    SELECT
        fund_management_rpt_cell_id,
        fmr_sheet_code,
        cell_id,
        row_index,
        column_index
    FROM {{ ref('dtm_fund_management_rpt_cell_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SHEET'
),

investment_fund AS (
    SELECT
        investment_fund_id,
        cl_fms_fund_tp_code,
        open_fund_tp_code
    FROM {{ ref('atm_investment_fund') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

establishment_license AS (
    SELECT
        ip_id,
        identification_issue_dt
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
),

fund_type AS (
    SELECT
        fund_type_id,
        fund_type_code
    FROM {{ ref('dtm_fund_type_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUND_TYPE'
),

row_indicator AS (
    -- Mã chỉ tiêu ghi trong ô cột mã (column_index = 2) của cùng dòng biểu mẫu / hàng động / bản nộp (O_QLQ_87)
    SELECT
        fmr_value.fmr_submission_code,
        fmr_value.fmr_sheet_code,
        fund_management_rpt_cell.row_index,
        COALESCE(fmr_value.dynamic_val_ind, 0)                                          AS dynamic_val_ind_key,
        COALESCE(fmr_value.dynamic_row_nbr, -1)                                         AS dynamic_row_nbr_key,
        MAX(fmr_value.cell_val)                                                         AS row_indicator_val_code
    FROM fmr_value
    INNER JOIN fund_management_rpt_cell
        ON fund_management_rpt_cell.fmr_sheet_code = fmr_value.fmr_sheet_code
        AND fund_management_rpt_cell.cell_id = fmr_value.cell_id
    WHERE fund_management_rpt_cell.column_index = 2
    GROUP BY 1, 2, 3, 4, 5
),

fmr_submission_period AS (
    SELECT
        fmr_submission.fmr_submission_id,
        fmr_submission.securities_distribution_agent_code,
        fmr_submission.submitted_dt,
        COALESCE(fmr_submission.period_tp_code, fmr_period.period_tp_code)              AS period_tp_code,
        fmr_submission.period_val,
        fmr_submission.rpt_year,
        fmr_submission.record_tp
    FROM fmr_submission
    LEFT JOIN fmr_period
        ON fmr_period.fmr_period_code = fmr_submission.fmr_period_code
),

fmr_value_period AS (
    SELECT
        fmr_value.*,
        fmr_submission_period.securities_distribution_agent_code,
        fmr_submission_period.submitted_dt,
        fmr_submission_period.period_tp_code,
        fmr_submission_period.period_val,
        fmr_submission_period.rpt_year,
        fmr_submission_period.record_tp,
        CASE fmr_submission_period.period_tp_code
            WHEN '3' THEN LAST_DAY(MAKE_DATE(fmr_submission_period.rpt_year,
                              CAST(COALESCE(NULLIF(REGEXP_EXTRACT(fmr_submission_period.period_val, '^T(\\d{2})/', 1), ''),
                                            fmr_submission_period.period_val) AS INT), 1))
            WHEN '4' THEN LAST_DAY(MAKE_DATE(fmr_submission_period.rpt_year,
                              3 * CAST(COALESCE(NULLIF(REGEXP_EXTRACT(fmr_submission_period.period_val, '^Q(\\d)/', 1), ''),
                                                fmr_submission_period.period_val) AS INT), 1))
            WHEN '5' THEN MAKE_DATE(fmr_submission_period.rpt_year, 6, 30)
            WHEN '6' THEN MAKE_DATE(fmr_submission_period.rpt_year, 12, 31)
        END                                                                             AS rpt_period_end_dt
    FROM fmr_value
    INNER JOIN fmr_submission_period
        ON fmr_submission_period.fmr_submission_id = fmr_value.fmr_submission_id
)

SELECT
    date_format(fmr_value_period.rpt_period_end_dt, 'yyyyMMdd')                                    AS rpt_period_end_dt_dim_id,
    CAST(fund_management_rpt_cell.fund_management_rpt_cell_id AS string)                           AS fund_management_rpt_cell_id,
    CAST(fund_type.fund_type_id AS string)                                                         AS fund_type_id,
    CAST(investment_fund.open_fund_tp_code AS string)                                              AS open_fund_tp_code,
<<<<<<< Updated upstream
    CAST(establishment_license.identification_issue_dt AS date)                                    AS fund_establishment_license_dt,
    CAST(fmr_value_period.fmr_val_code AS string)                                                  AS fmr_val_code,
    CAST(fmr_value_period.fmc_id AS string)                                                        AS fmc_id,
=======
    CAST(fmr_value_period.fmr_val_code AS string)                                                  AS fmr_val_code,
>>>>>>> Stashed changes
    CAST(fmr_value_period.fmc_code AS string)                                                      AS fmc_code,
    CAST(fmr_value_period.investment_fund_code AS string)                                          AS investment_fund_code,
    CAST(fmr_value_period.securities_distribution_agent_code AS string)                            AS securities_distribution_agent_code,
    CAST(fmr_value_period.foreign_fm_ou_code AS string)                                            AS foreign_fund_management_organization_unit_code,
    CAST(fmr_value_period.record_tp AS string)                                                     AS record_tp,
    CAST(fmr_value_period.period_tp_code AS string)                                                AS period_tp_code,
    CAST(fmr_value_period.period_val AS string)                                                    AS period_val,
    CAST(fmr_value_period.rpt_year AS int)                                                         AS rpt_year,
    CAST(fmr_value_period.dynamic_row_nbr AS int)                                                  AS dynamic_row_nbr,
    CAST(fmr_value_period.submitted_dt AS date)                                                    AS submitted_dt,
    CAST(fmr_value_period.cell_val AS string)                                                      AS cell_val,
    try_cast(regexp_replace(CAST(fmr_value_period.cell_val AS string), '%', '') AS decimal(38,10)) AS cell_numeric_val,
<<<<<<< Updated upstream
    CAST(fmr_value_period.src_stm_code AS string)                                                  AS src_stm_code,
    CAST(row_indicator.row_indicator_val_code AS string)                                           AS row_indicator_val_code
=======
    CAST(fmr_value_period.src_stm_code AS string)                                                  AS src_stm_code
>>>>>>> Stashed changes
FROM fmr_value_period
LEFT JOIN fund_management_rpt_cell
    ON fund_management_rpt_cell.fmr_sheet_code = fmr_value_period.fmr_sheet_code
    AND fund_management_rpt_cell.cell_id = fmr_value_period.cell_id
LEFT JOIN row_indicator
    ON row_indicator.fmr_submission_code = fmr_value_period.fmr_submission_code
    AND row_indicator.fmr_sheet_code = fmr_value_period.fmr_sheet_code
    AND row_indicator.row_index = fund_management_rpt_cell.row_index
    AND row_indicator.dynamic_val_ind_key = COALESCE(fmr_value_period.dynamic_val_ind, 0)
    AND row_indicator.dynamic_row_nbr_key = COALESCE(fmr_value_period.dynamic_row_nbr, -1)
LEFT JOIN investment_fund
    ON investment_fund.investment_fund_id = fmr_value_period.investment_fund_id
LEFT JOIN establishment_license
    ON establishment_license.ip_id = fmr_value_period.investment_fund_id
LEFT JOIN fund_type
    ON fund_type.fund_type_code = investment_fund.cl_fms_fund_tp_code
