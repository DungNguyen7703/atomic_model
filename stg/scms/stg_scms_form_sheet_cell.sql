/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_sheet_cell
* Program name: Staging SCMS.FORM_SHEET_CELL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot); kieu double sang decimal(38,10) (2 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: int sang decimal(38,10): default_value_legacy.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                         AS id
    , CAST(form_report_id AS bigint)           AS form_report_id
    , CAST(form_sheet_id AS bigint)            AS form_sheet_id
    , CAST(indicator_id AS bigint)             AS indicator_id
    , CAST(form_sheet_column_id AS bigint)     AS form_sheet_column_id
    , CAST(form_sheet_row_id AS bigint)        AS form_sheet_row_id
    , CAST(form_sheet_cell_input_id AS bigint) AS form_sheet_cell_input_id
    , CAST(format AS string)                   AS format
    , CAST(unit AS int)                        AS unit
    , CAST(default_value_legacy AS decimal(38,10))        AS default_value_legacy
    , CAST(sort_order AS int)                  AS sort_order
    , CAST(description AS string)              AS description
    , CAST(last_modified_at AS timestamp)      AS last_modified_at
    , CAST(active AS int)                      AS active
    , CAST(version AS int)                     AS version
    , CAST(label AS string)                    AS label
    , CAST(style_format AS string)             AS style_format
    , CAST(color AS string)                    AS color
    , CAST(alignment AS string)                AS alignment
    , CAST(bold AS int)                        AS bold
    , CAST(italic AS int)                      AS italic
    , CAST(uppercase AS int)                   AS uppercase
    , CAST(underline AS int)                   AS underline
    , CAST(character_format AS string)         AS character_format
    , CAST(filter_id AS string)                AS filter_id
    , CAST(sum_formula AS string)              AS sum_formula
    , CAST(formula_text AS string)             AS formula_text
    , CAST(formula AS string)                  AS formula
    , CAST(required AS int)                    AS required
    , CAST(template_form_report_id AS bigint)  AS template_form_report_id
    , CAST(editable AS int)                    AS editable
    , CAST(col_span AS bigint)                 AS col_span
    , CAST(dropdown_data AS string)            AS dropdown_data
    , CAST(default_value AS string)            AS default_value
    , CAST(max_value AS decimal(38,10))        AS max_value
    , CAST(min_value AS decimal(38,10))        AS min_value
    , CAST(data_type AS string)                AS data_type
    , CAST(cell_code AS string)                AS cell_code
    , CAST(last_modified_at_alt AS timestamp)  AS last_modified_at_alt
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(last_modified_by AS bigint)         AS last_modified_by
    , CAST(created_by AS bigint)               AS created_by
    , CAST(row_span AS bigint)                 AS row_span
    , CAST(record_status AS int)               AS record_status
    , CAST(is_total AS int)                    AS is_total
FROM {{ source('source_scms', 'raw_form_sheet_cell') }}