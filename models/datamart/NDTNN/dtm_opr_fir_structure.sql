/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fir_structure
* Program name: Dtm Opr Fir Structure
* Created by:
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Ban sao 1:1 (Operational) cua Atomic atm_fir_structure, giu nguyen ten va kieu cot Atomic, phuc vu
*   Data Explorer FIMS (job fims_ods_to_clickhouse doc truc tiep bang nay).
* - Chi sao chep ban ghi HIEN HANH cua Atomic: ds_rcrd_st = 'ACTIVE' AND ds_rcrd_end_dt = to_date('2400-01-01').
*   Ban ghi bien mat khoi nguon (da dong/xoa o Atomic) se duoc materialization scd2 dong lai
*   (ds_rcrd_st = 'INACTIVE') -> KHONG duoc bo dieu kien loc nay; job FIMS doc bang nay chi lay ds_rcrd_st = 'ACTIVE'.
* - Cung materialization voi Atomic (scd2): cac cot ky thuat ds_rcrd_st / ds_rcrd_eff_dt / ds_rcrd_end_dt /
*   ds_etl_pcs_tms do macro scd2 tu sinh, KHONG viet trong SELECT. Bang dich phai tao truoc bang DDL.
*--------------------------------------------------------------------*
*/

SELECT
    fir_structure_id,
    fir_structure_code,
    src_stm_code,
    structure_code,
    fir_id,
    fir_code,
    rpt_id,
    row_index,
    column_index,
    data_tp,
    row_path,
    column_path,
    section_id,
    section_tp_code,
    dynamic_ind,
    last_band_ind,
    total_row_ind,
    ordinal_column_ind,
    data_explorer_id,
    sort_order,
    excluded_by_config_ind,
    override_src
FROM {{ ref('atm_fir_structure') }}
WHERE ds_rcrd_st = 'ACTIVE'
