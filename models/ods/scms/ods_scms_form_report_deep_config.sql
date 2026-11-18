/*
*--------------------------------------------------------------------*
* Program code: ods_scms_form_report_deep_config
* Program name: ODS SCMS.FORM_REPORT_DEEP_CONFIG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH stg AS (

    SELECT
        id
        , form_report_id
        , eform_schema_json
        , excel_config_json
        , sheets_json
        , created_at
        , last_modified_at
        , eform_runtime_manifest_json
    FROM {{ ref('stg_scms_form_report_deep_config') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')

),

sheets AS (

    SELECT
        stg.id
        , stg.form_report_id
        , stg.eform_schema_json
        , stg.excel_config_json
        , stg.sheets_json
        , stg.created_at
        , stg.last_modified_at
        , stg.eform_runtime_manifest_json
        , sh.sheetId       AS sheet_id
        , sh.sheetCode     AS sheet_code
        , sh.cellCriteria  AS cell_criteria
    FROM stg
    LATERAL VIEW OUTER explode(
        from_json(
            stg.sheets_json
            , 'array<struct<sheetId:string,sheetCode:string,cellCriteria:array<struct<cellId:string>>>>'
        )
    ) s AS sh

)

SELECT
    sheets.id
    , sheets.form_report_id
    , sheets.eform_schema_json
    , sheets.excel_config_json
    , sheets.sheets_json
    , sheets.created_at
    , sheets.last_modified_at
    , sheets.eform_runtime_manifest_json
    , sheets.sheet_id
    , sheets.sheet_code
    , cc.cellId AS cell_id
FROM sheets
LATERAL VIEW OUTER explode(sheets.cell_criteria) c AS cc
