/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_custody_account_open_close_snpst
* Program name: Fact Custody Account Open Close Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-04		claude				Tao moi theo LLD TKNB 7ae22069 (TKNB Nhom 13 TTLK01, thay dtm_ttlk01_account_open_close_rpt):
*									star schema. snpst_dt_dim_id = ngay cuoi thang cua period_val (MM/yyyy); FK depository_member_dim
*									lookup theo TVLK (cell_val cua column_path 'TVLK'). Nhan cot BA dang 'SO LUONG ... > TRONG NUOC > CN'.
*--------------------------------------------------------------------*
*/

WITH statistical_report AS (
    SELECT
        row_index,
        period_val,
        column_path,
        cell_val,
        src_stm_code
    FROM {{ ref('atm_internal_statistical_report') }}
    WHERE src_stm_code = 'ISS_INTERNAL_STATISTICAL_REPORT'
        AND rpt_code = 'TTLK01'
        AND rpt_submission_stm_code = 'ICP'
        AND submission_status_code IN ('SUBMITTED','LATE_SUBMITTED')
        AND LAST_DAY(TO_DATE(CONCAT('01/', period_val), 'dd/MM/yyyy')) <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

member_dim AS (
    SELECT
        depository_member_dim_id,
        depository_member_nm
    FROM {{ ref('dtm_depository_member_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'ISS_INTERNAL_STATISTICAL_REPORT'
),

report_row AS (
    SELECT
        row_index,
        period_val,
        MAX(CASE WHEN column_path = 'TVLK' THEN cell_val END) AS depository_member_nm,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG ĐẦU KỲ > TRONG NƯỚC > CN' THEN cell_val END) AS int)  AS opening_domestic_individual_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG ĐẦU KỲ > TRONG NƯỚC > TC' THEN cell_val END) AS int)  AS opening_domestic_institution_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG ĐẦU KỲ > NƯỚC NGOÀI > CN' THEN cell_val END) AS int)  AS opening_foreign_individual_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG ĐẦU KỲ > NƯỚC NGOÀI > TC' THEN cell_val END) AS int)  AS opening_foreign_institution_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG MỞ TRONG KỲ > TRONG NƯỚC > CN' THEN cell_val END) AS int)  AS opened_domestic_individual_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG MỞ TRONG KỲ > TRONG NƯỚC > TC' THEN cell_val END) AS int)  AS opened_domestic_institution_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG MỞ TRONG KỲ > NƯỚC NGOÀI > CN' THEN cell_val END) AS int)  AS opened_foreign_individual_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG MỞ TRONG KỲ > NƯỚC NGOÀI > TC' THEN cell_val END) AS int)  AS opened_foreign_institution_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG ĐÓNG TRONG KỲ > TRONG NƯỚC > CN' THEN cell_val END) AS int)  AS closed_domestic_individual_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG ĐÓNG TRONG KỲ > TRONG NƯỚC > TC' THEN cell_val END) AS int)  AS closed_domestic_institution_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG ĐÓNG TRONG KỲ > NƯỚC NGOÀI > CN' THEN cell_val END) AS int)  AS closed_foreign_individual_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG ĐÓNG TRONG KỲ > NƯỚC NGOÀI > TC' THEN cell_val END) AS int)  AS closed_foreign_institution_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG CUỐI KỲ > TRONG NƯỚC > CN' THEN cell_val END) AS int)  AS closing_domestic_individual_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG CUỐI KỲ > TRONG NƯỚC > TC' THEN cell_val END) AS int)  AS closing_domestic_institution_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG CUỐI KỲ > NƯỚC NGOÀI > CN' THEN cell_val END) AS int)  AS closing_foreign_individual_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'SỐ LƯỢNG CUỐI KỲ > NƯỚC NGOÀI > TC' THEN cell_val END) AS int)  AS closing_foreign_institution_account_quantity,
        CAST(MAX(CASE WHEN column_path = 'TỔNG CỘNG' THEN cell_val END) AS int)  AS total_account_quantity,
        MAX(src_stm_code) AS src_stm_code
    FROM statistical_report
    GROUP BY
        row_index,
        period_val
)

SELECT
    date_format(LAST_DAY(TO_DATE(CONCAT('01/', report_row.period_val), 'dd/MM/yyyy')), 'yyyyMMdd') AS snpst_dt_dim_id,
    CAST(member_dim.depository_member_dim_id AS string)             AS depository_member_dim_id,
    CAST(report_row.row_index AS int)                               AS row_nbr,
    report_row.opening_domestic_individual_account_quantity,
    report_row.opening_domestic_institution_account_quantity,
    report_row.opening_foreign_individual_account_quantity,
    report_row.opening_foreign_institution_account_quantity,
    report_row.opened_domestic_individual_account_quantity,
    report_row.opened_domestic_institution_account_quantity,
    report_row.opened_foreign_individual_account_quantity,
    report_row.opened_foreign_institution_account_quantity,
    report_row.closed_domestic_individual_account_quantity,
    report_row.closed_domestic_institution_account_quantity,
    report_row.closed_foreign_individual_account_quantity,
    report_row.closed_foreign_institution_account_quantity,
    report_row.closing_domestic_individual_account_quantity,
    report_row.closing_domestic_institution_account_quantity,
    report_row.closing_foreign_individual_account_quantity,
    report_row.closing_foreign_institution_account_quantity,
    report_row.total_account_quantity,
    CAST(report_row.src_stm_code AS string)                         AS src_stm_code
FROM report_row
INNER JOIN member_dim
    ON member_dim.depository_member_nm = report_row.depository_member_nm
