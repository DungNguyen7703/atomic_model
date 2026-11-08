/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report
* Program name: Staging TMS.TMS_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-11-03
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-03		tuan.nguyenvanb		[MOI] Bo sung STG tinh toan tu stg compliance_report_*: danh muc bao cao dong UBCKNN va bo chi tieu: moi dong = 1 chi tieu cua 1 template. Tach TABLE_HEADER_LAYOUT (headerRows[0]) bang posexplode; doc stg_tms_compliance_report_form_template lat cat etl_date, loai ban ghi deleted.
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
FROM {{ ref('stg_tms_compliance_report_form_template') }} ft
LATERAL VIEW OUTER posexplode(
    from_json(
        ft.table_header_layout,
        'struct<headerRows:array<array<struct<label:string,columnCode:string>>>>'
    ).headerRows[0]
) t AS col_pos, ind
WHERE ft.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND ft.deleted = 0
  AND ind.columnCode IS NOT NULL
