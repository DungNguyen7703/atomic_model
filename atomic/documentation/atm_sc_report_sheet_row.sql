/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report_sheet_row
* Program name: Atomic Securities Company Report Sheet Row
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[MOI] Theo lld_SCMS_FORM_SHEET_ROW.yaml - Sinh moi. Nguon ods_scms_form_sheet_row.
*                                       FK hash truc tiep theo ID ky thuat nguon, khong crosswalk.
* 2026-11-13		claude		[Fix R-02] row_tp_code: CAST AS int theo DM/LLD (int); ODS row_type = bigint NUMBER(10,0)
*--------------------------------------------------------------------*
* 2026-11-13		claude		[DT-Review] CAST int->bigint (nguon NUMBER(10,0)/(18,0)): hierarchy_level_nbr, row_tp_code
*/

WITH fo_sh_ro AS (
    SELECT
        id
        , form_sheet_id
        , row_code
        , row_name
        , name_format
        , color
        , alignment
        , frozen_row
        , description
        , legacy_row_code
        , sync_row_code
        , hidden_row
        , hierarchy_level
        , editable
        , formula
        , parent_row_id
        , bold
        , italic
        , row_type
        , background_color
    FROM {{ ref('ods_scms_form_sheet_row') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_FORM_SHEET_ROW', "fo_sh_ro.id") }}            AS sc_rpt_sheet_row_id
    , CAST(fo_sh_ro.id AS string)                                                          AS sc_rpt_sheet_row_code
    , CAST('SCMS_FORM_SHEET_ROW' AS string)                                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_SHEET', "fo_sh_ro.form_sheet_id") }}     AS sc_rpt_sheet_id
    , CAST(fo_sh_ro.form_sheet_id AS string)                                               AS sc_rpt_sheet_code
    , CAST(fo_sh_ro.row_code AS string)                                                    AS row_code
    , CAST(fo_sh_ro.row_name AS string)                                                    AS row_nm
    , CAST(fo_sh_ro.name_format AS string)                                                 AS nm_format_code
    , CAST(fo_sh_ro.color AS string)                                                       AS color
    , CAST(fo_sh_ro.alignment AS string)                                                   AS alignment
    , CAST(fo_sh_ro.frozen_row AS int)                                                     AS frozen_row_ind
    , CAST(fo_sh_ro.description AS string)                                                 AS description
    , CAST(fo_sh_ro.legacy_row_code AS string)                                             AS legacy_row_code
    , CAST(fo_sh_ro.sync_row_code AS string)                                               AS sync_row_code
    , CAST(fo_sh_ro.hidden_row AS int)                                                     AS hidden_row_ind
    , CAST(fo_sh_ro.hierarchy_level AS int)                                                AS hierarchy_level_nbr
    , CAST(fo_sh_ro.editable AS int)                                                       AS editable_ind
    , CAST(fo_sh_ro.formula AS string)                                                     AS formula
    , {{ generate_surrogate_key_bigint('SCMS_FORM_SHEET_ROW', "fo_sh_ro.parent_row_id") }} AS parent_sc_rpt_sheet_row_id
    , CAST(fo_sh_ro.bold AS int)                                                           AS bold_ind
    , CAST(fo_sh_ro.italic AS int)                                                         AS italic_ind
    , CAST(fo_sh_ro.row_type AS int)                                                       AS row_tp_code
    , CAST(fo_sh_ro.background_color AS string)                                            AS background_color
FROM fo_sh_ro
