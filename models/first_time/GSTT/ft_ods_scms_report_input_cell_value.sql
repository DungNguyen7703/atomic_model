-- [FIRST-TIME] ft_ods_scms_report_input_cell_value: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_scms_report_input_cell_value (config ft_target='report_input_cell_value', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_scms_report_input_cell_value
* Program name: ODS SCMS.REPORT_INPUT_CELL_VALUE (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-23		tuan.nguyenvanb		Tao moi ban first-time tu ods daily (UAT). Bang ~64 trieu dong.
*--------------------------------------------------------------------*
*/

-- [BACKFILL-UAT-NEW] Bang ODS vat ly (UAT) KHONG co cot ds_snpst_dt: cot = id..ref_type, data_dt, ds_etl_pcs_tms -> ODS la append, partition data_dt (macro tu them ds_etl_pcs_tms).
-- data_dt la ngay cua tung dong nen moi ngay van la 1 partition nhu daily.
SELECT
    id
    , report_input_submission_id
    , sheet_id
    , section_id
    , cell_id
    , row_no
    , item_value
    , ref_type
    , data_dt
FROM {{ ft_ref('ft_stg_scms_report_input_cell_value') }}
-- [BACKFILL-UAT-ORIG] daily loc WHERE data_dt = ngay chay (bien ngay); first-time lay toan bo lich su, khong loc
