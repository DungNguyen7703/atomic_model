/*
*--------------------------------------------------------------------*
* Program code: ods_iss_flat_report
* Program name: ODS ISS Flat Report (master table)
* Created by: tra.nguyenthu
* Created date: 2026-09-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH metric_leaf AS (
    SELECT *
    FROM {{ ref('stg_iss_flat_metric_tree') }}
    WHERE is_leaf = 1
),

report_data AS (
    SELECT
        t.report_code, t.report_name, t.version, t.status, t.report_layout_type,
        ts.sheet_name, ts.row_start_position, ts.column_start_position,
        d.sheet_id,
        j.pos + 1 + COALESCE(d.data_index, 0) AS row_num,
        kv.key AS field_code,
        kv.value AS field_value,
        d.date_type, d.origin_date_value, d.day, d.month, d.quarter, d.half_year, d.year,
        s.submit_status, s.submit_source
    FROM {{ ref('stg_iss_fact_report_data') }} d
    JOIN {{ ref('stg_iss_input_report_submission') }} s ON d.input_report_submission_id = s.id AND s.deleted = 0
    JOIN {{ ref('stg_iss_input_report_template_sheet') }} ts ON d.sheet_id = ts.id AND ts.deleted = 0
    JOIN {{ ref('stg_iss_input_report_template') }} t ON ts.input_report_template_id = t.id AND t.deleted = 0 AND t.status = 'ACTIVE'
    LATERAL VIEW posexplode(
        from_json(
            CASE
                WHEN trim(d.json_data) LIKE '[%' THEN d.json_data
                ELSE concat('[', d.json_data, ']')
            END,
            'ARRAY<MAP<STRING, STRING>>'
        )
    ) j AS pos, json_map
    LATERAL VIEW explode(j.json_map) kv AS key, value

    WHERE d.deleted = 0
        AND s.submit_status IN ('SUBMITTED', 'LATE_SUBMITTED')
        AND date_format(d.ds_snpst_dt, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),

parsed_report_data AS (
    SELECT
        CASE dt.report_layout_type
            WHEN 'MIXED' THEN substring(dt.field_code, 1, instr(dt.field_code, '-') - 1)
            WHEN 'COLUMN_BASED' THEN dt.field_code
            WHEN 'ROW_BASED' THEN NULL
        END AS column_code,
        CASE dt.report_layout_type
            WHEN 'MIXED' THEN substring(dt.field_code, instr(dt.field_code, '-') + 1)
            WHEN 'COLUMN_BASED' THEN NULL
            WHEN 'ROW_BASED' THEN dt.field_code
        END AS row_code,
        dt.*
    FROM report_data dt
)

SELECT
    CAST(p.report_code AS string)          AS report_code
    , CAST(p.report_name AS string)         AS report_name
    , CAST(p.submit_source AS string)       AS submit_source
    , CAST(p.version AS int)                AS template_version
    , CAST(p.status AS string)              AS template_status
    , CAST(p.report_layout_type AS string)  AS report_layout_type
    , CAST(p.sheet_name AS string)          AS sheet_name
    , CAST(p.row_start_position AS string)  AS row_start_position
    , CAST(p.column_start_position AS string) AS column_start_position
    , CAST(p.row_num AS int)                AS row_num
    , CAST(coalesce(mc.data_type, mr.data_type) AS string) AS data_type
    , CAST(mc.`position` AS string)         AS col_position
    , CAST(mc.node_name_path AS string)     AS column_path
    , CAST(mr.`position` AS string)         AS row_position
    , CAST(mr.node_name_path AS string)     AS row_path
    , CAST(p.column_code AS string)         AS column_code
    , CAST(p.row_code AS string)            AS row_code
    , CAST(p.field_code AS string)          AS field_code
    , CAST(p.field_value AS string)         AS field_value
    , CAST(p.date_type AS string)           AS date_type
    , CAST(p.origin_date_value AS string)   AS origin_date_value
    , CAST(p.day AS int)                    AS report_day
    , CAST(p.month AS int)                  AS report_month
    , CAST(p.quarter AS int)                AS report_quarter
    , CAST(p.half_year AS int)              AS report_half_year
    , CAST(p.year AS int)                   AS report_year
    , CAST(p.submit_status AS string)       AS submit_status
FROM parsed_report_data p
LEFT JOIN metric_leaf mc
    ON CAST(p.column_code AS string) = CAST(mc.metric_code AS string) AND mc.metric_type = 'COLUMN' AND mc.sheet_id = p.sheet_id
LEFT JOIN metric_leaf mr
    ON CAST(p.row_code AS string) = CAST(mr.metric_code AS string) AND mr.metric_type = 'ROW' AND mr.sheet_id = p.sheet_id
