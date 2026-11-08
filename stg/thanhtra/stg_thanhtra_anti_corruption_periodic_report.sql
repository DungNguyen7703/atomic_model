/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_anti_corruption_periodic_report
* Program name: Staging THANHTRA.ANTI_CORRUPTION_PERIODIC_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(name AS string)             AS name
    , CAST(report_template AS string)  AS report_template
    , CAST(period_type AS string)      AS period_type
    , CAST(report_year AS int)         AS report_year
    , CAST(data_period_from AS date)   AS data_period_from
    , CAST(data_period_to AS date)     AS data_period_to
    , CAST(content AS string)          AS content
    , CAST(note AS string)             AS note
    , CAST(created_at AS date)         AS created_at
    , CAST(last_modified_at AS date)   AS last_modified_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(version AS bigint)          AS version
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_thanhtra', 'raw_anti_corruption_periodic_report') }}