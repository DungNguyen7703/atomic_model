/*
*--------------------------------------------------------------------*
* Program code: stg_tms_report_value
* Program name: Staging TMS.TMS_REPORT_VALUE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-03
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-03		tuan.nguyenvanb		[MOI] Bo sung STG tinh toan tu stg compliance_report_*: gia tri chi tieu bao cao dong theo tung lan nop: moi dong = 1 chi tieu cua 1 dong du lieu. Explode ROW_DATA (map<string,string>), lay indicator_label tu stg_tms_report; doc cac stg compliance_report_* lat cat etl_date, loai ban ghi deleted.
*--------------------------------------------------------------------*
*/

WITH exploded AS (
    SELECT
        d.id                  AS submission_id
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
    e.report_code                                                   AS report_code
    , e.indicator_code                                                AS indicator_code
    , tr.indicator_label                                              AS indicator_label
    , COALESCE(get_json_object(e.cell_raw, '$.value'), e.cell_raw)    AS indicator_value
    , CAST(e.submission_date AS date)                                 AS data_date
    , e.row_index                                                     AS row_index
    , e.submission_id                                                 AS submission_id
    , 'compliance_report_data'                                        AS _source_system
FROM exploded e
LEFT JOIN {{ ref('stg_tms_report') }} tr
    ON tr.report_template_id = e.report_template_id
    AND tr.indicator_code = e.indicator_code
    AND tr.ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
