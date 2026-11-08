/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_management_report_sheet_list
* Program name: Dtm Opr Fund Management Report Sheet List
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude (sync)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_fund_management_report_sheet_list_FMS_SHEET.csv
*                                       (commit 53443cc1 — danh sách sheet cho Data Explorer)
*                                       Driving: fmr_sheet (src FMS_SHEET), LEFT JOIN fund_management_report (src FMS_RPT_TEMP)
*                                       CHƯA CÓ model atm_fmr_sheet, atm_fund_management_report -> enabled: false
*                                       Đọc _hstr theo ds_snpst_dt (giả định scd4a) — xác nhận lại khi Atomic deploy
*--------------------------------------------------------------------*
*/

WITH fmr_sheet AS (
    -- atm_fmr_sheet đã chuyển grain theo cell (id + row + col) -> DISTINCT về 1 dòng/sheet
    SELECT DISTINCT
        fmr_sheet_code,
        fmr_id,
        fmr_code,
        fmr_sheet_nm,
        sheet_short_code,
        src_stm_code
    FROM {{ ref('atm_fmr_sheet') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SHEET'
),

fund_management_report AS (
    SELECT
        fmr_id,
        fmr_nm,
        fmr_tp_code,
        rpt_short_code
    FROM {{ ref('atm_fund_management_report') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_TEMP'
)

SELECT
    CAST(fmr_sheet.fmr_sheet_code AS string)                                                  AS fmr_sheet_code,
    CAST(fmr_sheet.fmr_code AS string)                                                        AS fmr_code,
    CAST(fund_management_report.fmr_nm AS string)                                             AS fmr_nm,
    CAST(fund_management_report.fmr_tp_code AS string)                                        AS fmr_tp_code,
    CAST(fund_management_report.rpt_short_code AS string)                                     AS rpt_short_code,
    CAST(fmr_sheet.fmr_sheet_nm AS string)                                                    AS fmr_sheet_nm,
    CAST(fmr_sheet.sheet_short_code AS string)                                                AS sheet_short_code,
    CAST(fmr_sheet.src_stm_code AS string)                                                    AS src_stm_code
FROM fmr_sheet
LEFT JOIN fund_management_report
    ON fund_management_report.fmr_id = fmr_sheet.fmr_id
