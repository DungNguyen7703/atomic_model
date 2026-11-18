/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fir_value
* Program name: Dtm Opr Fir Value
* Created by:
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Ban sao 1:1 (Operational) cua Atomic atm_fir_value, giu nguyen ten va kieu cot Atomic, phuc vu
*   Data Explorer FIMS (job fims_ods_to_clickhouse doc truc tiep bang nay).
* - Chi sao chep ban ghi HIEN HANH cua Atomic: ds_rcrd_st = 'ACTIVE' (bang upsert, khong co ds_rcrd_end_dt).
*   Ban ghi bien mat khoi nguon (da dong/xoa o Atomic) se duoc materialization upsert danh dau
*   ds_rcrd_st = 'INACTIVE' -> KHONG duoc bo dieu kien loc nay; job FIMS doc bang nay chi lay ds_rcrd_st = 'ACTIVE'.
* - Cac cot ky thuat ds_rcrd_st / ds_rcrd_isrt_dt / ds_rcrd_udt_dt / ds_etl_pcs_tms do materialization upsert
*   tu sinh, KHONG viet trong SELECT. Bang dich (va _hstr voi scd4a) phai tao truoc bang DDL.
*--------------------------------------------------------------------*
*/

SELECT
    fir_val_id,
    fir_val_code,
    src_stm_code,
    fir_structure_id,
    fir_structure_code,
    structure_code,
    rpt_log_id,
    rpt_id,
    fir_id,
    fir_code,
    reporting_entity_tp_code,
    reporting_entity_code,
    period_tp_code,
    period_val,
    rpt_year,
    rpt_day,
    submission_deadline_tms,
    submission_status_code,
    submission_status_tp_code,
    late_duration,
    total_row_ind,
    ordinal_column_ind,
    section_echo_ind,
    band_overflow_ind,
    static_copy_ind,
    rpt_marker_ind,
    dynamic_ind,
    dynamic_row_order,
    val_raw,
    submission_dt
FROM {{ ref('atm_fir_value') }}
WHERE ds_rcrd_st = 'ACTIVE'
