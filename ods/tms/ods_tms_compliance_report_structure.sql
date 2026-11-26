/*
*--------------------------------------------------------------------*
* Program code: ods_tms_compliance_report_structure
* Program name: ODS TMS.COMPLIANCE_REPORT_STRUCTURE
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

SELECT
    ft.id                  	 AS form_template_id
    , ft.template_id         AS template_id
    , tpl.template_code      AS template_code
    , ft.form_code           AS form_code
    , ft.form_name           AS form_name
    , ft.description         AS form_description
    , col_pos                AS column_index
    , ind.columnCode         AS column_code
    , ind.label              AS column_label
    , ft.is_mandatory        AS is_mandatory
    , ft.display_order       AS display_order
    , ft.status              AS status
    , ft.version             AS version
    , ft.aggregation_mode    AS aggregation_mode
    , ft.require_signature   AS require_signature
    , ft.approval_type       AS approval_type
    , ft.key_columns         AS key_columns
FROM {{ ref('stg_tms_compliance_report_form_template') }} ft
LEFT JOIN {{ ref('stg_tms_compliance_report_template') }} tpl
    ON tpl.id = ft.template_id
    AND tpl.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND tpl.deleted = 0
LATERAL VIEW OUTER posexplode(
    from_json(
        ft.table_header_layout,
        'struct<headerRows:array<array<struct<label:string,columnCode:string>>>>'
    ).headerRows[0]
) t AS col_pos, ind
WHERE ft.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND ft.deleted = 0
  --AND ind.columncode IS NOT NULL