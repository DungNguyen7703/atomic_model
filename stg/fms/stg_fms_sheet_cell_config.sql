/*
*--------------------------------------------------------------------*
* Program code: stg_fms_sheet_cell_config
* Program name: Staging FMS.SHEET_CELL_CONFIG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , HEX(sheet_id)                      AS sheet_id
    , CAST(row_index AS bigint)          AS row_index
    , CAST(col_index AS bigint)          AS col_index
    , CAST(cell_key AS string)           AS cell_key
    , CAST(indicator_type AS string)     AS indicator_type
    , CAST(format_code AS string)        AS format_code
    , CAST(unit_scale AS string)         AS unit_scale
    , CAST(target_code_flag AS int)      AS target_code_flag
    , CAST(identifier_flag AS int)       AS identifier_flag
    , CAST(identifier_code AS string)    AS identifier_code
    , CAST(section_id AS string)         AS section_id
    , CAST(section_type AS string)       AS section_type
    , CAST(section_anchor AS int)        AS section_anchor
    , CAST(section_end AS int)           AS section_end
    , CAST(mapping_target AS string)     AS mapping_target
    , CAST(mapping_field AS string)      AS mapping_field
    , CAST(mapping_field_type AS string) AS mapping_field_type
    , CAST(mapping_label AS string)      AS mapping_label
    , CAST(required_field AS int)        AS required_field
    , CAST(min_value AS string)          AS min_value
    , CAST(max_value AS string)          AS max_value
    , CAST(dropdown_data AS string)      AS dropdown_data
    , CAST(formula AS string)            AS formula
    , CAST(cell_meta_json AS string)     AS cell_meta_json
    , CAST(date_created AS timestamp)    AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS timestamp)   AS date_modified
    , CAST(modify_by AS string)          AS modify_by
FROM {{ source('source_fms', 'raw_sheet_cell_config') }}