-- [FIRST-TIME] ft_ods_tms_compliance_report_value: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_tms_compliance_report_value (config ft_target='compliance_report_value', macro macros/first_time). Partition data_dt.
/*
*--------------------------------------------------------------------*
* Program code: ft_ods_tms_compliance_report_value
* Program name: [FIRST-TIME] ODS TMS.COMPLIANCE_REPORT_VALUE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-19		tuan.nguyenvanb		[MOI] Ban khoi tao cua ods_tms_compliance_report_value: doc 2 ban ft_stg (data, master - FULL bang, data_dt = ngay thay doi cuoi);
*										bo loc data_dt = etl_date; cac STG snapshot (form, form_template) va ODS structure lay ban chup MOI NHAT (MAX ds_snpst_dt)
*										vi first-time khong co snapshot theo tung ngay. Join layout/structure dung cot that: form_layout theo (report_form_id = form_id,
*										column_code), structure theo (form_template_id, column_code) - ban daily dang tham chieu report_form_id/indicator_code khong ton tai trong exploded/structure.
*										Them cot data_dt cuoi SELECT (partition ODS).
*--------------------------------------------------------------------*
*/

WITH com_rpt_form AS (
    SELECT * FROM {{ ref('stg_tms_compliance_report_form') }}
    WHERE ds_snpst_dt = (SELECT MAX(ds_snpst_dt) FROM {{ ref('stg_tms_compliance_report_form') }})
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

struc AS (
    -- Ban chup MOI NHAT cua ODS structure; 1 dong / (form_template_id, column_code)
    SELECT form_template_id, column_code, MAX(column_label) AS column_label
    FROM {{ ref('ods_tms_compliance_report_structure') }}
    WHERE ds_snpst_dt = (SELECT MAX(ds_snpst_dt) FROM {{ ref('ods_tms_compliance_report_structure') }})
    GROUP BY form_template_id, column_code
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
        , d.data_dt           AS data_dt
    FROM {{ ft_ref('ft_stg_tms_compliance_report_data') }} d
    JOIN com_rpt_form f
        ON f.id = d.report_form_id
    JOIN {{ ft_ref('ft_stg_tms_compliance_report_master') }} m
        ON m.id = f.report_master_id
        AND m.deleted = 0
    JOIN {{ ref('stg_tms_compliance_report_form_template') }} ft
        ON ft.id = f.form_template_id
        AND ft.ds_snpst_dt = (SELECT MAX(ds_snpst_dt) FROM {{ ref('stg_tms_compliance_report_form_template') }})
        AND ft.deleted = 0
    LATERAL VIEW explode(from_json(d.row_data, 'map<string,string>')) kv AS key, value
    WHERE d.deleted = 0
    -- [BACKFILL-ORIG] daily: d.data_dt = etl_date, m.data_dt = etl_date, ft.ds_snpst_dt = etl_date
)

SELECT
    e.form_code                                                                      AS form_code
    , e.column_code                                                                  AS column_code
    , COALESCE(fl.column_label, fl.business_key, tr.column_label)                    AS column_label
    , COALESCE(get_json_object(e.cell_raw, '$.value'), e.cell_raw)                   AS cell_val
    , CAST(e.submission_date AS date)                                                AS submission_dt
    , e.row_index                                                                    AS row_index
    , e.submission_id                                                                AS submission_id
    , e.form_id                                                                      AS form_id
    , e.period_type                                                                  AS period_tp
    , e.period_value                                                                 AS period_val
    , e.period_year                                                                  AS period_year
    , e.submitter_type                                                               AS submitter_tp
    , e.upload_date                                                                  AS upload_dt
    , e.file_name                                                                    AS file_name
    , CAST(e.data_dt AS date)                                                        AS data_dt
FROM exploded e
LEFT JOIN form_layout fl
    ON fl.report_form_id = e.form_id
    AND fl.column_code = e.column_code
LEFT JOIN struc tr
    ON tr.form_template_id = e.report_template_id
    AND tr.column_code = e.column_code
