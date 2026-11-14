/*
*--------------------------------------------------------------------*
* Program code: atm_dr_submission_history
* Program name: Atomic Dynamic Report Submission History - Multi Source
* Created by: claude (sync)
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		claude (sync)		Chuyển sang multi-source (UNION ALL model ephemeral theo nguồn). Nhánh: FMS_REPORT_HISTORY, SCMS_REPORT_HISTORY.
*                                       Fact Append partition submission_dt: mỗi nhánh tự lọc submission_dt = etl_date.
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ref('atm_dr_submission_history_fms_report_history') }}
UNION ALL
SELECT * FROM {{ ref('atm_dr_submission_history_scms_report_history') }}
