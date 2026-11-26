/*
*--------------------------------------------------------------------*
* Program code: ods_tms_compliance_report_value
* Program name: ODS TMS.COMPLIANCE_REPORT_VALUE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-11
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-19		tuan.nguyenvanb		LEFT JOIN ods_tms_compliance_report_structure loc ds_snpst_dt = etl_date (ODS structure doi sang snapshot).
* 2026-11-19		[SUA LOI UNRESOLVED_COLUMN] 2 LEFT JOIN cuoi dung ten cot khong ton tai: tr.report_template_id -> tr.form_template_id; tr.indicator_code/e.indicator_code -> column_code;
*									e.report_form_id -> e.form_id; them cot cuoi data_dt (partition ODS, bang vat ly co data_dt).
* 2026-11-11		tuan.nguyenvanb		[MOI] Chuyen tu stg_tms_report_value len tang ODS (giu nguyen logic va thu tu cot): explode ROW_DATA (map<string,string>), ten chi tieu theo layout cua DUNG report_form_id (dynamicBlocks + headerRows), thieu thi fallback ods_tms_report (khong con loc ds_snpst_dt vi bang ODS khong co cot nay). Phai chay SAU ods_tms_report. Strategy append KHONG partition_by -> INSERT OVERWRITE ca bang = truncate insert.
*--------------------------------------------------------------------*
*/

WITH com_rpt_form AS (
    SELECT * FROM {{ ref('stg_tms_compliance_report_form') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND deleted = 0
),

layout_dynamic AS (
    -- Cot dong (ma chung khoan...): $.dynamicBlocks.*.columns[*] cua DUNG report_form_id
    SELECT
        rf.id                       AS report_form_id
        , c.col.columnCode          AS column_code
        , c.col.businessKey         AS business_key
        , c.col.columnLabel         AS column_label
    FROM com_rpt_form rf
    LATERAL VIEW explode(
        from_json(
            rf.table_header_layout,
            'struct<dynamicBlocks:map<string,struct<columns:array<struct<columnCode:string,businessKey:string,columnLabel:string>>>>>'
        ).dynamicBlocks
    ) b AS block_key, block
    LATERAL VIEW explode(b.block.columns) c AS col
    WHERE c.col.columnCode IS NOT NULL
),

layout_fixed AS (
    -- Cot co dinh: $.headerRows[*][*] (columnCode, label); COL_01 = Ngay / ma chung khoan
    SELECT
        rf.id                       AS report_form_id
        , h.cell.columnCode         AS column_code
        , CASE WHEN h.cell.columnCode = 'COL_01' THEN 'Ngày/ mã chứng khoán' ELSE h.cell.label END AS business_key
        , CASE WHEN h.cell.columnCode = 'COL_01' THEN 'Ngày/ mã chứng khoán' ELSE h.cell.label END AS column_label
    FROM com_rpt_form rf
    LATERAL VIEW explode(
        from_json(
            rf.table_header_layout,
            'struct<headerRows:array<array<struct<columnCode:string,label:string>>>>'
        ).headerRows
    ) r AS hrow
    LATERAL VIEW explode(r.hrow) h AS cell
    WHERE h.cell.columnCode IS NOT NULL
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
        , f.id                AS form_id
        , f.period_type       AS period_type
        , f.period_value      AS period_value
        , f.period_year       AS period_year
        , f.submitter_type    AS submitter_type
        , f.upload_date       AS upload_date
        , f.file_name         AS file_name
        , d.row_index         AS row_index
        , f.form_template_id  AS report_template_id
        , ft.form_code        AS form_code
        , m.submission_date   AS submission_date
        , kv.key              AS column_code
        , kv.value            AS cell_raw
        , d.data_dt           AS data_dt   -- [SUA 2026-11-19] cot partition ODS (append partition data_dt): = etl_date (da loc d.data_dt = etl_date)
    FROM {{ ref('stg_tms_compliance_report_data') }} d
    JOIN com_rpt_form f
        ON f.id = d.report_form_id
    JOIN {{ ref('stg_tms_compliance_report_master') }} m
        ON m.id = f.report_master_id
        AND m.data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND m.deleted = 0
    JOIN {{ ref('stg_tms_compliance_report_form_template') }} ft
        ON ft.id = f.form_template_id
        AND ft.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND ft.deleted = 0
    LATERAL VIEW explode(from_json(d.row_data, 'map<string,string>')) kv AS key, value
    WHERE d.data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND d.deleted = 0
)
SELECT
    e.form_code                                                                   	AS form_code
    , e.column_code                                                              	AS column_code
    , COALESCE(fl.column_label, fl.business_key, tr.column_label)                	AS column_label
    , COALESCE(get_json_object(e.cell_raw, '$.value'), e.cell_raw)                  AS cell_val
    , CAST(e.submission_date AS date)                                               AS submission_dt
    , e.row_index                                                                   AS row_index
    , e.submission_id                                                               AS submission_id
    , e.form_id                                                              		AS form_id
    , e.period_type                                                                 AS period_tp
    , e.period_value                                                                AS period_val
    , e.period_year                                                                 AS period_year
    , e.submitter_type                                                              AS submitter_tp
    , e.upload_date                                                                 AS upload_dt
    , e.file_name                                                                   AS file_name
    , CAST(e.data_dt AS date)                                                       AS data_dt   -- [SUA 2026-11-19] cot cuoi SELECT (partition ODS)
FROM exploded e
LEFT JOIN {{ ref('ods_tms_compliance_report_structure') }} tr
    ON tr.form_template_id = e.report_template_id   -- [SUA 2026-11-19] ODS structure khong co report_template_id: khoa form template = form_template_id
    AND tr.column_code = e.column_code              -- [SUA 2026-11-19] bo indicator_code (khong ton tai o exploded/structure) -> column_code
    AND tr.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')   -- [2026-11-19] ODS structure snapshot: chi join ban chup ngay chay
LEFT JOIN form_layout fl
    ON fl.report_form_id = e.form_id                -- [SUA 2026-11-19] exploded dat ten form_id (khong co report_form_id)
    AND fl.column_code = e.column_code