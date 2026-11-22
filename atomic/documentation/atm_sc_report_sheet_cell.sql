/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report_sheet_cell
* Program name: Atomic Securities Company Report Sheet Cell
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH fo_sh_ce AS (
    SELECT
        id
        , form_sheet_id
        , form_sheet_row_id
        , form_sheet_column_id
        , form_sheet_cell_input_id
        , cell_code
        , indicator_id
        , format
        , unit
        , default_value_legacy
        , description
        , label
        , style_format
        , color
        , alignment
        , bold
        , italic
        , uppercase
        , underline
        , character_format
        , required
        , template_form_report_id
        , editable
        , col_span
        , dropdown_data
        , default_value
        , max_value
        , min_value
        , data_type
        , row_span
        , is_total
    FROM {{ ref('ods_scms_form_sheet_cell') }}
),

ca_fi AS (
    SELECT
        code
    FROM {{ ref('ods_scms_cat_filter') }}
),

fo_in_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_form_indicator_input') }}
),

fo_in_in_2 AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_form_indicator_input') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_FORM_SHEET_CELL', "fo_sh_ce.id") }}                       AS sc_rpt_sheet_cell_id
    , CAST(fo_sh_ce.id AS string)                                                                    AS sc_rpt_sheet_cell_code
    , CAST('SCMS_FORM_SHEET_CELL' AS string)                                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_SHEET', "fo_sh_ce.form_sheet_id") }}               AS sc_rpt_sheet_id
    , CAST(fo_sh_ce.form_sheet_id AS string)                                                         AS sc_rpt_sheet_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_SHEET_ROW', "fo_sh_ce.form_sheet_row_id") }}       AS sc_rpt_sheet_row_id
    , CAST(fo_sh_ce.form_sheet_row_id AS string)                                                     AS sc_rpt_sheet_row_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_SHEET_COLUMN', "fo_sh_ce.form_sheet_column_id") }} AS sc_rpt_sheet_column_id
    , CAST(fo_sh_ce.form_sheet_column_id AS string)                                                  AS sc_rpt_sheet_column_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_INDICATOR_INPUT', "fo_in_in.code") }}              AS sc_rpt_ind_id
    , CAST(fo_in_in.code AS string)                                                                  AS sc_rpt_ind_code
    , CAST(fo_sh_ce.cell_code AS string)                                                             AS cell_code
    , {{ generate_surrogate_key_bigint('SCMS_FORM_INDICATOR_INPUT', "fo_in_in_2.code") }}            AS legacy_sc_rpt_ind_id
    , CAST(fo_in_in_2.code AS string)                                                                AS legacy_sc_rpt_ind_code
    , CAST(fo_sh_ce.format AS string)                                                                AS format
    , CAST(fo_sh_ce.unit AS string)                                                                  AS unit
    , CAST(fo_sh_ce.default_value_legacy AS string)                                                  AS legacy_default_val
    , CAST(fo_sh_ce.description AS string)                                                           AS description
    , CAST(fo_sh_ce.label AS string)                                                                 AS label_nm
    , CAST(fo_sh_ce.style_format AS string)                                                          AS style_format_code
    , CAST(fo_sh_ce.color AS string)                                                                 AS color
    , CAST(fo_sh_ce.alignment AS string)                                                             AS alignment
    , CAST(fo_sh_ce.bold AS int)                                                                     AS bold_ind
    , CAST(fo_sh_ce.italic AS int)                                                                   AS italic_ind
    , CAST(fo_sh_ce.uppercase AS int)                                                                AS uppercase_ind
    , CAST(fo_sh_ce.underline AS int)                                                                AS underline_ind
    , CAST(fo_sh_ce.character_format AS string)                                                      AS character_format_code
    , CAST(ca_fi.code AS string)                                                                     AS filter_code
    , CAST(fo_sh_ce.required AS int)                                                                 AS required_ind
    , {{ generate_surrogate_key_bigint('SCMS_FORM_REPORT', "fo_sh_ce.template_form_report_id") }}    AS template_sc_rpt_id
    , CAST(fo_sh_ce.template_form_report_id AS string)                                               AS template_sc_rpt_code
    , CAST(fo_sh_ce.editable AS int)                                                                 AS editable_ind
    , CAST(fo_sh_ce.col_span AS int)                                                                 AS column_span_nbr
    , CAST(fo_sh_ce.dropdown_data AS string)                                                         AS dropdown_data
    , CAST(fo_sh_ce.default_value AS string)                                                         AS default_val
    , CAST(fo_sh_ce.max_value AS string)                                                             AS max_val
    , CAST(fo_sh_ce.min_value AS string)                                                             AS min_val
    , CAST(fo_sh_ce.data_type AS string)                                                             AS data_tp_code
    , CAST(fo_sh_ce.row_span AS int)                                                                 AS row_span_nbr
    , CAST(fo_sh_ce.is_total AS int)                                                                 AS is_total_ind
FROM fo_sh_ce
    LEFT JOIN ca_fi ON fo_sh_ce.Id = ca_fi.Id
    LEFT JOIN fo_in_in ON fo_sh_ce.FORM_SHEET_CELL_INPUT_ID = fo_in_in.ID
    LEFT JOIN fo_in_in_2 ON fo_sh_ce.INDICATOR_ID = fo_in_in_2.ID