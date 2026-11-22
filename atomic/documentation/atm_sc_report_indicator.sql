/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report_indicator
* Program name: Atomic Securities Company Report Indicator
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_FORM_INDICATOR_INPUT.yaml (9 cot, Relative/scd2); khoi phuc tu git 77a9749^. sc_rpt_ind_id hash SCMS_FORM_INDICATOR_INPUT theo CODE (BK) - khop sc_rpt_ind_id/legacy_sc_rpt_ind_id trong atm_sc_report_sheet_cell
* 2026-11-13		claude		[MOI] Khu trung theo code (ROW_NUMBER, rn=1, id lon nhat) vi hash theo CODE chu khong phai ID nguon va scd2 khong tu bo trung khoa
*--------------------------------------------------------------------*
*/

WITH fo_in_in AS (
    SELECT
        code
        , item_name
        , description
        , data_type
        , category
        , source_entity_code
        , selection_list_source
    FROM {{ ref('ods_scms_form_indicator_input') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_FORM_INDICATOR_INPUT', "fo_in_in.code") }} AS sc_rpt_ind_id
    , CAST(fo_in_in.code AS string)                                                   AS sc_rpt_ind_code
    , CAST('SCMS_FORM_INDICATOR_INPUT' AS string)                                     AS src_stm_code
    , CAST(fo_in_in.item_name AS string)                                              AS sc_rpt_ind_nm
    , CAST(fo_in_in.description AS string)                                            AS description
    , CAST(fo_in_in.data_type AS string)                                              AS data_tp_code
    , CAST(fo_in_in.category AS string)                                               AS category
    , CAST(fo_in_in.source_entity_code AS string)                                     AS src_entity_code
    , CAST(fo_in_in.selection_list_source AS string)                                  AS selection_list_src
FROM fo_in_in