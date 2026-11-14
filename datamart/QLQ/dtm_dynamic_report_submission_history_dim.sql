/*
*--------------------------------------------------------------------*
* Program code: dtm_dynamic_report_submission_history_dim
* Program name: Dtm Dynamic Report Submission History Dimension
* Created by: claude (sync)
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		claude (sync)		Tạo mới theo LLD DTM_QLQ_dynamic_report_submission_history_dim_FMS_REPORT_HISTORY.csv
*                                       (scd4a, PK = dr_submission_history_id direct). Atomic dr_submission_history là Fact Append
*                                       (không có ds_rcrd_st) -> đọc mọi partition, 1 dòng/report_log_id.
*                                       Điều kiện LLD "submission_dt = :etl_date" được COMMENT: mcr_scd4a soft-delete key vắng mặt
*                                       trong input -> lọc theo ngày sẽ INACTIVE toàn bộ lần nộp cũ, trong khi opr val/indicator cần
*                                       TOÀN BỘ lịch sử nộp (lần nộp thắng). Tiền lệ: dtm_fct_fund_management_rpt_cell_val. Chờ sửa LLD.
*--------------------------------------------------------------------*
*/

WITH dr_submission_history AS (
    SELECT
        dr_submission_history_id,
        dr_submission_history_code,
        rpt_code,
        rpt_tp,
        audit_rpt_ind,
        object_id,
        object_nm,
        object_tp,
        object_sub_tp,
        period_tp,
        period_val,
        submission_dt,
        rpt_version,
        src_stm_code,
        row_number() OVER (
            PARTITION BY dr_submission_history_code
            ORDER BY submission_dt DESC, ds_etl_pcs_tms DESC
        ) AS rn
    FROM {{ ref('atm_dr_submission_history') }}
    WHERE src_stm_code = 'FMS_REPORT_HISTORY'
        AND submission_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
)

SELECT
    CAST(dr_submission_history_id AS string)        AS dr_submission_history_id,
    CAST(dr_submission_history_code AS string)      AS dr_submission_history_code,
    CAST(rpt_code AS string)                        AS submission_rpt_code,
    CAST(rpt_tp AS string)                          AS rpt_tp,
    CAST(audit_rpt_ind AS int)                      AS audit_rpt_ind,
    CAST(object_id AS string)                       AS object_id,
    CAST(object_nm AS string)                       AS object_nm,
    CAST(object_tp AS string)                       AS object_tp,
    CAST(object_sub_tp AS string)                   AS object_sub_tp,
    CAST(period_tp AS string)                       AS period_tp,
    CAST(period_val AS string)                      AS period_val,
    CAST(submission_dt AS date)                     AS submission_dt,
    CAST(rpt_version AS int)                        AS rpt_version,
    CAST(src_stm_code AS string)                    AS src_stm_code
FROM dr_submission_history
WHERE rn = 1
