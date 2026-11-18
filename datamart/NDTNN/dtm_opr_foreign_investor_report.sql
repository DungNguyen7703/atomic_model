/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_foreign_investor_report
* Program name: Dtm Opr Foreign Investor Report
* Created by:
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Ban sao 1:1 (Operational) cua Atomic atm_foreign_investor_report, giu nguyen ten va kieu cot Atomic, phuc vu
*   Data Explorer FIMS (job fims_ods_to_clickhouse doc truc tiep bang nay).
* - Chi sao chep ban ghi HIEN HANH cua Atomic: ds_rcrd_st = 'ACTIVE' AND ds_rcrd_end_dt = to_date('2400-01-01').
*   Ban ghi bien mat khoi nguon (da dong/xoa o Atomic) se duoc materialization scd2 dong lai
*   (ds_rcrd_st = 'INACTIVE') -> KHONG duoc bo dieu kien loc nay; job FIMS doc bang nay chi lay ds_rcrd_st = 'ACTIVE'.
* - Cung materialization voi Atomic (scd2): cac cot ky thuat ds_rcrd_st / ds_rcrd_eff_dt / ds_rcrd_end_dt /
*   ds_etl_pcs_tms do macro scd2 tu sinh, KHONG viet trong SELECT. Bang dich phai tao truoc bang DDL.
*--------------------------------------------------------------------*
*/

SELECT
    fir_id,
    fir_code,
    src_stm_code,
    rpt_id,
    rpt_code,
    rpt_nm,
    legal_basis,
    rpt_status,
    sheet_code,
    sheet_nm,
    sheet_index
FROM {{ ref('atm_foreign_investor_report') }}
WHERE ds_rcrd_st = 'ACTIVE' AND ds_rcrd_end_dt = to_date('2400-01-01')
