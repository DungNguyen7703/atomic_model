/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_investor_report_value
* Program name: Fact Foreign Investor Report Value
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-17		nghia.le			Bo Foreign Investor Reporting Entity Dimension khoi fact (theo DTM moi + bang mart thuc te khong con cot
*									foreign_investor_reporting_entity_dim_id): bo cot FK, CTE fi_re_en_di va LEFT JOIN tuong ung.
* 2026-10-13		nghia.le			[RULE BAO CAO DINH KY / BAT THUONG] them cot rpt_dt_dim_id (FK ngay chot so lieu = atm_fir_value.rpt_day, NULL neu nguon khong co - khong fallback o datamart) o CUOI bang
*                                       - can ALTER TABLE datamart.uat_dtm.fct_foreign_investor_report_value ADD COLUMNS (rpt_dt_dim_id string).
*                                       Dung cho K_NDTNN_20/21/22: bao cao dinh ky IBOU9 den moc nua thang, bao cao bat thuong tu sau moc.
*
*--------------------------------------------------------------------*
* Ghi chu:
* - EAV 1 dong = 1 o bao cao dong FIMS (fir_value). Doc dung theo LLD
*   DTM_NDTNN_fct_foreign_investor_report_value.csv, khong loc etl_date.
* - foreign_investor_report_structure_dim_id: tra theo fir_structure_code
*   (SHEET_ID || INDICATOR_UID), khong tra theo structure_code vi
*   INDICATOR_UID chi duy nhat trong 1 sheet.
* - val_nbr: ep tu val_raw (nguon chi co VALUE_RAW) - bo dau nhay dau,
*   NULL neu khong ep duoc.
*--------------------------------------------------------------------*
*/

WITH fi_va AS (
    SELECT
        submission_dt,
        fir_structure_code,
        rpt_log_id,
        dynamic_row_order,
        period_tp_code,
        period_val,
        rpt_year,
        submission_status_code,
        late_duration,
        total_row_ind,
        section_echo_ind,
        band_overflow_ind,
        static_copy_ind,
        rpt_marker_ind,
        val_raw,
        src_stm_code,
        rpt_day   -- ngày chốt số liệu GỐC, NULL khi nguồn không có (không fallback ở đây — ClickHouse tự ifNull theo ngày nộp)
    FROM {{ ref('atm_fir_value') }}
    WHERE src_stm_code = 'FIMS_FIR_VALUE'
),

cd_dt_di AS (
    SELECT
        cdr_dt_dim_id,
        cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
),

fi_re_st_di AS (
    SELECT
        foreign_investor_report_structure_dim_id,
        fir_structure_code
    FROM {{ ref('dtm_foreign_investor_report_structure_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)                                                              AS submission_dt_dim_id,
    CAST(rp_cd_dt_di.cdr_dt_dim_id AS string)                                                           AS rpt_dt_dim_id,
    CAST(fi_re_st_di.foreign_investor_report_structure_dim_id AS string)                                AS foreign_investor_report_structure_dim_id,
    CAST(fi_va.rpt_log_id AS string)                                                                    AS rpt_log_id,
    CAST(fi_va.dynamic_row_order AS int)                                                                AS dynamic_row_order,
    CAST(fi_va.period_tp_code AS string)                                                                AS period_tp_code,
    CAST(fi_va.period_val AS string)                                                                    AS period_val,
    CAST(fi_va.rpt_year AS int)                                                                         AS rpt_year,
    CAST(fi_va.submission_status_code AS string)                                                        AS submission_status_code,
    CAST(fi_va.late_duration AS int)                                                                    AS late_duration,
    CAST(fi_va.total_row_ind AS int)                                                                    AS total_row_ind,
    CAST(fi_va.section_echo_ind AS int)                                                                 AS section_echo_ind,
    CAST(fi_va.band_overflow_ind AS int)                                                                AS band_overflow_ind,
    CAST(fi_va.static_copy_ind AS int)                                                                  AS static_copy_ind,
    CAST(fi_va.rpt_marker_ind AS int)                                                                   AS rpt_marker_ind,
    CAST(fi_va.val_raw AS string)                                                                       AS val_raw,
    CAST(fi_va.src_stm_code AS string)                                                                  AS src_stm_code
FROM fi_va
LEFT JOIN cd_dt_di
    ON  cd_dt_di.cdr_dt = fi_va.submission_dt
LEFT JOIN cd_dt_di rp_cd_dt_di
    ON  rp_cd_dt_di.cdr_dt = fi_va.rpt_day
LEFT JOIN fi_re_st_di
    ON  fi_re_st_di.fir_structure_code = fi_va.fir_structure_code
