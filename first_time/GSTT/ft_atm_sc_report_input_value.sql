-- [FIRST-TIME] ft_atm_sc_report_input_value: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_sc_report_input_value (config ft_target='sc_report_input_value', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report_input_value
* Program name: Atomic Securities Company Report Input Value (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-23		tuan.nguyenvanb		Tao moi ban first-time tu atomic daily (UAT). Bang ~64 trieu dong.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] daily la merge (macro tu them ds_snpst_dt = ngay chay); first-time: append + ds_snpst_dt = data_dt tung dong
WITH re_in_ce_va AS (
    SELECT
        id
        , report_input_submission_id
        , sheet_id
        , section_id
        , cell_id
        , row_no
        , item_value
        , ref_type
        , data_dt   -- [BACKFILL-UAT-NEW] dung de gan ds_snpst_dt
    FROM {{ ft_ref('ft_ods_scms_report_input_cell_value') }}
    -- [BACKFILL-UAT-ORIG] daily loc where data_dt = ngay chay (bien ngay); first-time lay toan bo lich su, khong loc
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_REPORT_INPUT_CELL_VALUE', "re_in_ce_va.id") }}                           AS sc_rpt_input_val_id
    , CAST(re_in_ce_va.id AS string)                                                                                AS sc_rpt_input_val_code
    , CAST('SCMS_REPORT_INPUT_CELL_VALUE' AS string)                                                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_REPORT_INPUT_SUBMISSION', "re_in_ce_va.report_input_submission_id") }} AS sc_rpt_input_submission_id
    , CAST(re_in_ce_va.report_input_submission_id AS string)                                                        AS sc_rpt_input_submission_code
    , CAST(re_in_ce_va.sheet_id AS string)                                                                          AS sheet_id
    , CAST(re_in_ce_va.section_id AS string)                                                                        AS section_id
    , CAST(re_in_ce_va.cell_id AS string)                                                                           AS cell_id
    , CAST(re_in_ce_va.row_no AS int)                                                                               AS row_index
    , CAST(re_in_ce_va.item_value AS string)                                                                        AS cell_val
    , CAST(re_in_ce_va.ref_type AS string)                                                                          AS ref_tp_code
    , CAST(re_in_ce_va.data_dt AS date)                                                                             AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = data_dt (daily merge: = ngay chay)
FROM re_in_ce_va
