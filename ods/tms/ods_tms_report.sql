/*
*--------------------------------------------------------------------*
* Program code: ods_tms_report
* Program name: ODS TMS.TMS_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-11-11
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-11		tuan.nguyenvanb		[MOI] Chuyen tu stg_tms_report len tang ODS (giu nguyen logic va thu tu cot): giai phang TABLE_HEADER_LAYOUT (headerRows[0]) bang posexplode, moi dong = 1 chi tieu cua 1 template; doc stg_tms_compliance_report_form_template/_template lat cat etl_date, loai deleted. Strategy append KHONG partition_by -> INSERT OVERWRITE ca bang = truncate insert; khong co cot ds_snpst_dt.
*--------------------------------------------------------------------*
*/

SELECT
    ft.id                  AS report_template_id
    , ft.template_id         AS template_group_id
    , ft.form_code           AS report_code
    , ft.form_name           AS report_name
    , ft.description         AS report_description
    , ft.is_mandatory        AS is_mandatory
    , ft.display_order       AS display_order
    , ft.status              AS status
    , ft.version             AS version
    , ft.aggregation_mode    AS aggregation_mode
    , ft.require_signature   AS require_signature
    , ft.approval_type       AS approval_type
    , ft.key_columns         AS key_columns
    , col_pos                AS indicator_order
    , ind.columnCode         AS indicator_code
    , ind.label              AS indicator_label
    , ft.created_at          AS created_at
    , ft.updated_at          AS updated_at
    , 'compliance_report_form_template' AS _source_system
    , tpl.template_code      AS template_code
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
  AND ind.columnCode IS NOT NULL
