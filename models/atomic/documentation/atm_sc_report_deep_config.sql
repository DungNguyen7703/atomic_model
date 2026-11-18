/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report_deep_config
* Program name: Atomic Securities Company Report Deep Config
* Created by: tuan.nguyenvanb
* Created date: 2026-10-23
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-23		tuan.nguyenvanb		[MOI, theo LLD lld_SCMS_FORM_REPORT_DEEP_CONFIG.yaml] Sinh moi - phuc vu
*                                       loc SHEET_ID theo sheetCode (06620/06608/06622/06610) cho VCSH/LNST CTCK
*                                       o dtm_fct_stock_portfolio_snpst. Nguon ods_scms_form_report_deep_config
*                                       da explode SHEETS_JSON thanh sheet_id/sheet_code/cell_id -> grain thuc te
*                                       la 1 dong / (config, sheet, cell), KHONG phai 1 dong / bieu mau nhu
*                                       notes LLD. Vi vay sc_rpt_deep_config_id (PK) hash theo
*                                       (ID, sheet_id, cell_id) thay vi chi ID nhu LLD (hash chi ID se trung
*                                       khoa) - CAN Data Modeler xac nhan lai.
*--------------------------------------------------------------------*
*/

WITH fo_re_de_co AS (
    SELECT
        id
        , form_report_id
        , sheet_id
        , sheet_code
        , cell_id
    FROM {{ ref('ods_scms_form_report_deep_config') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT_DEEP_CONFIG', "CONCAT_WS('|', fo_re_de_co.id, COALESCE(fo_re_de_co.sheet_id, ''), COALESCE(fo_re_de_co.cell_id, ''))") }} AS sc_rpt_deep_config_id
    , CAST(fo_re_de_co.id AS string)                                                          AS sc_rpt_deep_config_code
    , CAST('SCMS_FORM_REPORT_DEEP_CONFIG' AS string)                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "fo_re_de_co.form_report_id") }}   AS sc_rpt_id
    , CAST(fo_re_de_co.form_report_id AS string)                                              AS sc_rpt_code
    , CAST(fo_re_de_co.sheet_id AS string)                                                    AS sheet_id
    , CAST(fo_re_de_co.sheet_code AS string)                                                  AS sheet_code
    , CAST(fo_re_de_co.cell_id AS string)                                                     AS cell_id
FROM fo_re_de_co
