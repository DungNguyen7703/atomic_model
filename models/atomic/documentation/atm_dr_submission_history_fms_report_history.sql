/*
*--------------------------------------------------------------------*
* Program code: atm_dr_submission_history_fms_report_history
* Program name: Atomic Dynamic Report Submission History FMS.REPORT_HISTORY
* Created by: claude (sync)
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		claude (sync)		Tách từ atm_dr_submission_history thành ephemeral theo nguồn (BK = report_log_id; lọc ngay_nop = etl_date).
*                                       ODS FMS chưa có RPT_VERSION -> rpt_version = NULL. Cột riêng SCMS = NULL để UNION ALL (đặt SAU submission_dt).
*--------------------------------------------------------------------*
*/

WITH re_hi AS (
    SELECT
        report_log_id
        , report_code
        , report_type
        , audit
        , object_id
        , object_name
        , object_type
        , object_subtype
        , period_type
        , period_value
        , ngay_nop
    FROM {{ source('source_fms_bcd', 'raw_report_history') }}
    WHERE CAST(ngay_nop AS date) = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND report_log_id IS NOT NULL
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_REPORT_HISTORY', "report_log_id") }}    AS dr_submission_history_id
    , CAST(report_log_id AS string)                                               AS dr_submission_history_code
    , CAST('FMS_REPORT_HISTORY' AS string)                                        AS src_stm_code
    , CAST(report_code AS string)                                                 AS rpt_code
    , CAST(report_type AS string)                                                 AS rpt_tp
    , CAST(audit AS int)                                                          AS audit_rpt_ind
    , CAST(object_id AS string)                                                   AS object_id
    , CAST(object_name AS string)                                                 AS object_nm
    , CAST(object_type AS string)                                                 AS object_tp
    , CAST(object_subtype AS string)                                              AS object_sub_tp
    , CAST(period_type AS string)                                                 AS period_tp
    , CAST(period_value AS string)                                                AS period_val
    , CAST(NULL AS int)                                                           AS rpt_version
    , CAST(ngay_nop AS date)                                                      AS submission_dt
    , CAST(NULL AS string)                                                        AS form_rpt_code
    , CAST(NULL AS int)                                                           AS rpt_year
    , CAST(NULL AS string)                                                        AS object_code
    , CAST(NULL AS string)                                                        AS listing_exchange
    , CAST(NULL AS string)                                                        AS business_lines
FROM re_hi
