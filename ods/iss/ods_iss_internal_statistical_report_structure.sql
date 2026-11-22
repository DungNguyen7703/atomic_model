/*
*--------------------------------------------------------------------*
* Program code: ods_iss_internal_statistical_report_structure
* Program name: ODS ISS.INTERNAL_STATISTICAL_REPORT_STRUCTURE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH metric AS (
    SELECT
        id,
        sheet_id,
        parent_id,
        node_name,
        metric_code,
        `position`,
        data_type,
        metric_type,
        created_at,
        updated_at
    FROM {{ ref('stg_iss_input_report_metric') }}
    WHERE deleted = 0
),

sheet AS (
    SELECT
        id,
        input_report_template_id
    FROM {{ ref('stg_iss_input_report_template_sheet') }}
    WHERE deleted = 0
),

template AS (
    SELECT
        id,
        report_code,
        report_layout_type,
        version
    FROM {{ ref('stg_iss_input_report_template') }}
    WHERE deleted = 0
),

-- Level 0: node goc cua moi cay (parent_id IS NULL)
lv0 AS (
    SELECT
        id, sheet_id, metric_type,
        CAST(node_name AS string) AS node_name_path
    FROM metric
    WHERE parent_id IS NULL
),

lv1 AS (
    SELECT c.id, c.sheet_id, c.metric_type, concat(p.node_name_path, ' > ', c.node_name) AS node_name_path
    FROM metric c
    JOIN lv0 p ON p.id = c.parent_id AND p.sheet_id = c.sheet_id AND p.metric_type = c.metric_type
),

lv2 AS (
    SELECT c.id, c.sheet_id, c.metric_type, concat(p.node_name_path, ' > ', c.node_name) AS node_name_path
    FROM metric c
    JOIN lv1 p ON p.id = c.parent_id AND p.sheet_id = c.sheet_id AND p.metric_type = c.metric_type
),

lv3 AS (
    SELECT c.id, c.sheet_id, c.metric_type, concat(p.node_name_path, ' > ', c.node_name) AS node_name_path
    FROM metric c
    JOIN lv2 p ON p.id = c.parent_id AND p.sheet_id = c.sheet_id AND p.metric_type = c.metric_type
),

lv4 AS (
    SELECT c.id, c.sheet_id, c.metric_type, concat(p.node_name_path, ' > ', c.node_name) AS node_name_path
    FROM metric c
    JOIN lv3 p ON p.id = c.parent_id AND p.sheet_id = c.sheet_id AND p.metric_type = c.metric_type
),

lv5 AS (
    SELECT c.id, c.sheet_id, c.metric_type, concat(p.node_name_path, ' > ', c.node_name) AS node_name_path
    FROM metric c
    JOIN lv4 p ON p.id = c.parent_id AND p.sheet_id = c.sheet_id AND p.metric_type = c.metric_type
),

lv6 AS (
    SELECT c.id, c.sheet_id, c.metric_type, concat(p.node_name_path, ' > ', c.node_name) AS node_name_path
    FROM metric c
    JOIN lv5 p ON p.id = c.parent_id AND p.sheet_id = c.sheet_id AND p.metric_type = c.metric_type
),

lv7 AS (
    SELECT c.id, c.sheet_id, c.metric_type, concat(p.node_name_path, ' > ', c.node_name) AS node_name_path
    FROM metric c
    JOIN lv6 p ON p.id = c.parent_id AND p.sheet_id = c.sheet_id AND p.metric_type = c.metric_type
),

lv8 AS (
    SELECT c.id, c.sheet_id, c.metric_type, concat(p.node_name_path, ' > ', c.node_name) AS node_name_path
    FROM metric c
    JOIN lv7 p ON p.id = c.parent_id AND p.sheet_id = c.sheet_id AND p.metric_type = c.metric_type
),

lv9 AS (
    SELECT c.id, c.sheet_id, c.metric_type, concat(p.node_name_path, ' > ', c.node_name) AS node_name_path
    FROM metric c
    JOIN lv8 p ON p.id = c.parent_id AND p.sheet_id = c.sheet_id AND p.metric_type = c.metric_type
),

metric_tree AS (
    SELECT * FROM lv0
    UNION ALL SELECT * FROM lv1
    UNION ALL SELECT * FROM lv2
    UNION ALL SELECT * FROM lv3
    UNION ALL SELECT * FROM lv4
    UNION ALL SELECT * FROM lv5
    UNION ALL SELECT * FROM lv6
    UNION ALL SELECT * FROM lv7
    UNION ALL SELECT * FROM lv8
    UNION ALL SELECT * FROM lv9
),

-- Node nao co it nhat 1 con (xuat hien lam parent_id cua metric khac) -> KHONG phai leaf
has_child AS (
    SELECT DISTINCT parent_id AS id
    FROM metric
    WHERE parent_id IS NOT NULL
)

SELECT
    CAST(metric.id AS string)                                       AS id
    , CAST(template.report_code AS string)                          AS report_code
    , CAST(template.report_layout_type AS string)                   AS report_layout_type
    , CAST(template.version AS int)                                 AS template_version
    , CAST(metric.sheet_id AS string)                               AS sheet_id
    , CAST(metric.metric_type AS string)                            AS metric_type
    , CAST(metric.metric_code AS string)                            AS metric_code
    , CAST(metric.`position` AS string)                             AS position
    , CAST(metric.data_type AS string)                              AS data_type
    , CAST(upper(metric_tree.node_name_path) AS string)             AS node_name_path
    , CAST(CASE WHEN has_child.id IS NULL THEN 1 ELSE 0 END AS int) AS is_leaf
    , CAST(metric.created_at AS timestamp)                          AS created_at
    , CAST(metric.updated_at AS timestamp)                          AS updated_at
FROM metric
JOIN metric_tree
    ON  metric_tree.id = metric.id
JOIN sheet
    ON  sheet.id = metric.sheet_id
JOIN template
    ON  template.id = sheet.input_report_template_id
LEFT JOIN has_child
    ON  has_child.id = metric.id
