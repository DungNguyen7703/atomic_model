-- ────────────────────────────────────────────────────────────
-- Model : qlq_fct_fund_management_rpt_cell_val_flat
-- Type  : FACT
-- 2026-10-14 claude: khởi tạo từ flat-table/QLQ/02_populate_qlq_flat_tables.sql #17 (commit d18cdaa0).
--                    ck_snapshot: job lọc submitted_dt = etl_date nên ds_snpst_dt (= etl_date) = submitted_dt;
--                    DROP PARTITION ds_snpst_dt tương đương DELETE theo submitted_dt của thiết kế.
--                    Flat giữ toàn bộ kỳ/bản nộp (O_QLQ_32), không lọc
--                    theo ngày cuối kỳ. rpt_period_end_cdr_dt suy từ dim_id như các job qlq_fct_* khác.
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        rpt_period_end_dt_dim_id,
        fund_management_rpt_cell_id,
        fund_type_id,
        open_fund_tp_code,
        fund_establishment_license_dt,
        fmr_val_code,
        fmc_id,
        fmc_code,
        investment_fund_code,
        securities_distribution_agent_code,
        foreign_fund_management_organization_unit_code,
        record_tp,
        period_tp_code,
        period_val,
        rpt_year,
        dynamic_row_nbr,
        submitted_dt,
        cell_val,
        cell_numeric_val,
        src_stm_code
    FROM {{ ref('dtm_fct_fund_management_rpt_cell_val') }}
    -- WHERE submitted_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

dim_rpt_cell AS (
    SELECT
        fund_management_rpt_cell_id,
        fmr_sheet_code,
        cell_id,
        fmr_code,
        fmr_nm,
        fmr_tp_code,
        rpt_short_code,
        rpt_group_code,
        stm_object_tp_code,
        cl_fms_fund_tp_code,
        version_nbr,
        legal_basis,
        fmr_sheet_nm,
        sheet_short_code,
        sheet_index,
        investment_portfolio_indicator,
        row_index,
        column_index,
        row_span,
        column_span,
        label_nm,
        row_stt_code,
        row_indicator_code,
        row_indicator_nm,
        row_label_nm,
        column_label_nm
    FROM {{ ref('dtm_fund_management_rpt_cell_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
      AND src_stm_code = 'FMS_SHEET'
),

dim_fund_type AS (
    SELECT
        fund_type_id,
        fund_type_code,
        fund_type_nm,
        open_fund_indicator
    FROM {{ ref('dtm_fund_type_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
      AND src_stm_code = 'FMS_FUND_TYPE'
)

SELECT
    f.rpt_period_end_dt_dim_id,
    f.fund_management_rpt_cell_id,
    f.fund_type_id,
    f.open_fund_tp_code,
    f.fund_establishment_license_dt,
    f.fmr_val_code,
    f.fmc_id,
    f.fmc_code,
    f.investment_fund_code,
    f.securities_distribution_agent_code,
    f.foreign_fund_management_organization_unit_code,
    f.record_tp,
    f.period_tp_code,
    f.period_val,
    f.rpt_year,
    f.dynamic_row_nbr,
    f.submitted_dt,
    f.cell_val,
    f.cell_numeric_val,
    f.src_stm_code,
    TO_DATE(f.rpt_period_end_dt_dim_id, 'yyyyMMdd')      AS rpt_period_end_cdr_dt,
    c.fmr_sheet_code,
    c.cell_id,
    c.fmr_code,
    c.fmr_nm,
    c.fmr_tp_code,
    c.rpt_short_code,
    c.rpt_group_code,
    c.stm_object_tp_code,
    c.cl_fms_fund_tp_code,
    c.version_nbr,
    c.legal_basis,
    c.fmr_sheet_nm,
    c.sheet_short_code,
    c.sheet_index,
    c.investment_portfolio_indicator,
    c.row_index,
    c.column_index,
    c.row_span,
    c.column_span,
    c.label_nm,
    c.row_stt_code,
    c.row_indicator_code,
    c.row_indicator_nm,
    c.row_label_nm,
    c.column_label_nm,
    ft.fund_type_code,
    ft.fund_type_nm,
    ft.open_fund_indicator

FROM fact f
LEFT JOIN dim_rpt_cell c
    ON c.fund_management_rpt_cell_id = f.fund_management_rpt_cell_id
LEFT JOIN dim_fund_type ft
    ON ft.fund_type_id = f.fund_type_id
