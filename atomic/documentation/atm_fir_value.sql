/*
*--------------------------------------------------------------------*
* Program code: atm_fir_value
* Program name: Atomic Foreign Investor Report Value
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH fi_va AS (
    SELECT
        indicator_uid
        , report_log_id
        , rpt_id
        , sheet_id
        , object_type
        , object_id
        , period_type
        , period_value
        , year_value
        , day_report
        , han_nop
        , late_status
        , late_status_code
        , late_duration
        , is_total_row
        , is_ordinal_col
        , is_section_echo
        , is_band_overflow
        , is_static_copy
        , is_template_marker
        , is_dynamic
        , row_order
        , value_raw
        , ngay_nop
    FROM {{ source('source_fims_bcd', 'raw_fir_value') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_FIR_VALUE', "concat_ws('-', fi_va.report_log_id, fi_va.sheet_id, fi_va.indicator_uid, fi_va.row_order)") }} AS fir_val_id
    , CAST(concat_ws('-', fi_va.report_log_id, fi_va.sheet_id, fi_va.indicator_uid, fi_va.row_order) AS string)                                        AS fir_val_code
    , CAST('FIMS_FIR_VALUE' AS string)                                                                                                                 AS src_stm_code
    , {{ generate_surrogate_key_bigint('FIMS_FIR_STRUCTURE', "concat_ws('-', fi_va.sheet_id, fi_va.indicator_uid)") }}                                 AS fir_structure_id
    , CAST(concat_ws('-', fi_va.sheet_id, fi_va.indicator_uid) AS string)                                                                              AS fir_structure_code
    , CAST(fi_va.indicator_uid AS string)                                                                                                              AS structure_code
    , CAST(fi_va.report_log_id AS string)                                                                                                              AS rpt_log_id
    , CAST(fi_va.rpt_id AS string)                                                                                                                     AS rpt_id
    , {{ generate_surrogate_key_bigint('FIMS_FOREIGN_INVESTOR_REPORT', "fi_va.sheet_id") }}                                                            AS fir_id
    , CAST(fi_va.sheet_id AS string)                                                                                                                   AS fir_code
    , CAST(fi_va.object_type AS int)                                                                                                                   AS reporting_entity_tp_code
    , CAST(fi_va.object_id AS string)                                                                                                                  AS reporting_entity_code
    , CAST(fi_va.period_type AS string)                                                                                                                AS period_tp_code
    , CAST(fi_va.period_value AS string)                                                                                                               AS period_val
    , CAST(fi_va.year_value AS int)                                                                                                                    AS rpt_year
    , CAST(fi_va.day_report AS date)                                                                                                                   AS rpt_day
    , CAST(fi_va.han_nop AS timestamp)                                                                                                                 AS submission_deadline_tms
    , CAST(fi_va.late_status AS string)                                                                                                                AS submission_status_code
    , CAST(fi_va.late_status_code AS int)                                                                                                              AS submission_status_tp_code
    , CAST(fi_va.late_duration AS int)                                                                                                                 AS late_duration
    , CAST(fi_va.is_total_row AS int)                                                                                                                  AS total_row_ind
    , CAST(fi_va.is_ordinal_col AS int)                                                                                                                AS ordinal_column_ind
    , CAST(fi_va.is_section_echo AS int)                                                                                                               AS section_echo_ind
    , CAST(fi_va.is_band_overflow AS int)                                                                                                              AS band_overflow_ind
    , CAST(fi_va.is_static_copy AS int)                                                                                                                AS static_copy_ind
    , CAST(fi_va.is_template_marker AS int)                                                                                                            AS rpt_marker_ind
    , CAST(fi_va.is_dynamic AS int)                                                                                                                    AS dynamic_ind
    , CAST(fi_va.row_order AS int)                                                                                                                     AS dynamic_row_order
    , CAST(fi_va.value_raw AS string)                                                                                                                  AS val_raw
    , CAST(fi_va.ngay_nop AS date)                                                                                                                     AS submission_dt
FROM fi_va