/*
*--------------------------------------------------------------------*
* Program code: ods_tms_report_value
* Program name: ODS TMS.TMS_REPORT_VALUE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-11
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-11		tuan.nguyenvanb		[MOI] Chuyen tu stg_tms_report_value len tang ODS (giu nguyen logic va thu tu cot): explode ROW_DATA (map<string,string>), ten chi tieu theo layout cua DUNG report_form_id (dynamicBlocks + headerRows), thieu thi fallback ods_tms_report (khong con loc ds_snpst_dt vi bang ODS khong co cot nay). Phai chay SAU ods_tms_report. Strategy append KHONG partition_by -> INSERT OVERWRITE ca bang = truncate insert.
*--------------------------------------------------------------------*
*/

WITH layout_dynamic AS (
    -- Cot dong (ma chung khoan...): $.dynamicBlocks.*.columns[*] cua DUNG report_form_id
    SELECT
        lf.id                       AS report_form_id
        , c.col.columnCode          AS column_code
        , c.col.businessKey         AS business_key
        , c.col.columnLabel         AS column_label
    FROM {{ ref('stg_tms_compliance_report_form') }} lf
    LATERAL VIEW explode(
        from_json(
            lf.table_header_layout,
            'struct<dynamicBlocks:map<string,struct<columns:array<struct<columnCode:string,businessKey:string,columnLabel:string>>>>>'
        ).dynamicBlocks
    ) b AS block_key, block
    LATERAL VIEW explode(b.block.columns) c AS col
    WHERE lf.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND lf.deleted = 0
      AND c.col.columnCode IS NOT NULL
),

layout_fixed AS (
    -- Cot co dinh: $.headerRows[*][*] (columnCode, label); COL_01 = Ngay / ma chung khoan
    SELECT
        lf.id                       AS report_form_id
        , h.cell.columnCode         AS column_code
        , CASE WHEN h.cell.columnCode = 'COL_01' THEN 'Ngày/ mã chứng khoán' ELSE h.cell.label END AS business_key
        , CASE WHEN h.cell.columnCode = 'COL_01' THEN 'Ngày/ mã chứng khoán' ELSE h.cell.label END AS column_label
    FROM {{ ref('stg_tms_compliance_report_form') }} lf
    LATERAL VIEW explode(
        from_json(
            lf.table_header_layout,
            'struct<headerRows:array<array<struct<columnCode:string,label:string>>>>'
        ).headerRows
    ) r AS hrow
    LATERAL VIEW explode(r.hrow) h AS cell
    WHERE lf.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND lf.deleted = 0
      AND h.cell.columnCode IS NOT NULL
),

form_layout AS (
    -- COL_xx -> ten chi tieu theo layout cua DUNG report_form_id; 1 dong / (form, column_code). Uu tien cot dong, thieu thi lay cot co dinh.
    SELECT
        report_form_id
        , column_code
        , COALESCE(MAX(CASE WHEN src = 1 THEN business_key END), MAX(CASE WHEN src = 2 THEN business_key END)) AS business_key
        , COALESCE(MAX(CASE WHEN src = 1 THEN column_label END), MAX(CASE WHEN src = 2 THEN column_label END)) AS column_label
    FROM (
        SELECT report_form_id, column_code, business_key, column_label, 1 AS src FROM layout_dynamic
        UNION ALL
        SELECT report_form_id, column_code, business_key, column_label, 2 AS src FROM layout_fixed
    ) u
    GROUP BY report_form_id, column_code
),

exploded AS (
    SELECT
        d.id                  AS submission_id
        , f.id                AS report_form_id
        , f.period_type       AS period_type
        , f.period_value      AS period_value
        , f.period_year       AS period_year
        , f.submitter_type    AS submitter_type
        , f.upload_date       AS upload_date
        , f.file_name         AS file_name
        , MAX(CASE WHEN kv.key = 'COL_01' THEN COALESCE(get_json_object(kv.value, '$.value'), kv.value) END)
            OVER (PARTITION BY d.report_form_id, d.row_index) AS row_date_key
        , d.row_index         AS row_index
        , f.form_template_id  AS report_template_id
        , ft.form_code        AS report_code
        , m.submission_date   AS submission_date
        , kv.key              AS indicator_code
        , kv.value            AS cell_raw
    FROM {{ ref('stg_tms_compliance_report_data') }} d
    JOIN {{ ref('stg_tms_compliance_report_form') }} f
        ON f.id = d.report_form_id
        AND f.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    JOIN {{ ref('stg_tms_compliance_report_master') }} m
        ON m.id = f.report_master_id
        AND m.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    JOIN {{ ref('stg_tms_compliance_report_form_template') }} ft
        ON ft.id = f.form_template_id
        AND ft.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    LATERAL VIEW explode(from_json(d.row_data, 'map<string,string>')) kv AS key, value
    WHERE d.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND d.deleted = 0
      AND f.deleted = 0
      AND m.deleted = 0
)
SELECT
    e.report_code                                                                   AS report_code
    , e.indicator_code                                                              AS indicator_code
    , COALESCE(fl.column_label, fl.business_key, tr.indicator_label)                AS indicator_label
    , COALESCE(get_json_object(e.cell_raw, '$.value'), e.cell_raw)                  AS indicator_value
    , CAST(e.submission_date AS date)                                               AS data_date
    , e.row_index                                                                   AS row_index
    , e.submission_id                                                               AS submission_id
    , 'compliance_report_data'                                                      AS _source_system
    , e.report_form_id                                                              AS report_form_id
    , e.period_type                                                                 AS period_type
    , e.period_value                                                                AS period_value
    , e.period_year                                                                 AS period_year
    , e.submitter_type                                                              AS submitter_type
    , e.upload_date                                                                 AS upload_date
    , e.file_name                                                                   AS file_name
    , e.row_date_key                                                                AS row_date_key
    , COALESCE(fl.business_key, fl.column_label, tr.indicator_label)                AS indicator_business_key
FROM exploded e
LEFT JOIN {{ ref('ods_tms_report') }} tr
    ON tr.report_template_id = e.report_template_id
    AND tr.indicator_code = e.indicator_code
LEFT JOIN form_layout fl
    ON fl.report_form_id = e.report_form_id
    AND fl.column_code = e.indicator_code
