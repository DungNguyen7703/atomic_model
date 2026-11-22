/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report_sheet
* Program name: Atomic Securities Company Report Sheet
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[MOI] Theo lld_SCMS_FORM_SHEET.yaml - Sinh moi. Nguon ods_scms_form_sheet.
*                                       FK hash truc tiep theo ID ky thuat nguon, khong crosswalk.
*                                       FORM_SHEET_ID (self-ref) hash truc tiep theo FORM_SHEET_ID; sub_title_alignment lay tu SUB_TITLE_ENABLED (theo LLD).
* 2026-11-13		claude		[Fix R-01] record_tp_code: CAST AS int theo DM/LLD (int); ODS record_type = int NUMBER(2,0)
*--------------------------------------------------------------------*
*/

WITH fo_sh AS (
    SELECT
        id
        , form_report_id
        , sheet_code
        , sheet_name
        , main_title
        , sub_title
        , cover_page
        , paper_size
        , paper_orientation
        , note
        , signatory
        , report_style
        , sub_title_position
        , sub_title_enabled
        , form_sheet_id
        , legacy_sheet_code
        , company_info
        , national_heading
        , rptdetailid
        , sync_column_code
        , record_type
        , columnorder
        , start_row
        , stt_column_code
    FROM {{ ref('ods_scms_form_sheet') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_FORM_SHEET', "fo_sh.id") }}              AS sc_rpt_sheet_id
    , CAST(fo_sh.id AS string)                                                        AS sc_rpt_sheet_code
    , CAST('SCMS_FORM_SHEET' AS string)                                               AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "fo_sh.form_report_id") }} AS sc_rpt_id
    , CAST(fo_sh.form_report_id AS string)                                            AS sc_rpt_code
    , CAST(fo_sh.sheet_code AS string)                                                AS sheet_code
    , CAST(fo_sh.sheet_name AS string)                                                AS sheet_nm
    , CAST(fo_sh.main_title AS string)                                                AS main_title
    , CAST(fo_sh.sub_title AS string)                                                 AS sub_title
    , CAST(fo_sh.cover_page AS int)                                                   AS cover_page_ind
    , CAST(fo_sh.paper_size AS string)                                                AS paper_size
    , CAST(fo_sh.paper_orientation AS string)                                         AS paper_orientation
    , CAST(fo_sh.note AS string)                                                      AS note
    , CAST(fo_sh.signatory AS string)                                                 AS signatory
    , CAST(fo_sh.report_style AS string)                                              AS rpt_style_code
    , CAST(fo_sh.sub_title_position AS string)                                        AS sub_title_position
    , CAST(fo_sh.sub_title_enabled AS string)                                         AS sub_title_alignment
    , {{ generate_surrogate_key_bigint('SCMS_FORM_SHEET', "fo_sh.form_sheet_id") }}   AS parent_sc_rpt_sheet_id
    , CAST(fo_sh.form_sheet_id AS string)                                             AS parent_sc_rpt_sheet_code
    , CAST(fo_sh.legacy_sheet_code AS string)                                         AS legacy_sheet_code
    , CAST(fo_sh.company_info AS string)                                              AS company_info
    , CAST(fo_sh.national_heading AS string)                                          AS national_heading
    , CAST(fo_sh.rptdetailid AS string)                                               AS legacy_sheet_detail_id
    , CAST(fo_sh.sync_column_code AS string)                                          AS sync_column_code
    , CAST(fo_sh.record_type AS int)                                                  AS record_tp_code
    , CAST(fo_sh.columnorder AS string)                                               AS column_order
    , CAST(fo_sh.start_row AS int)                                                    AS start_row_nbr
    , CAST(fo_sh.stt_column_code AS string)                                           AS sequence_column_code
FROM fo_sh
