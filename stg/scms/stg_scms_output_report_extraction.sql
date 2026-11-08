/*
*--------------------------------------------------------------------*
* Program code: stg_scms_output_report_extraction
* Program name: Staging SCMS.OUTPUT_REPORT_EXTRACTION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (10 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (3 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: from_date, to_date, aggregation_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(form_report_id AS bigint)      AS form_report_id
    , CAST(from_date AS date)        AS from_date
    , CAST(to_date AS date)          AS to_date
    , CAST(aggregation_date AS date) AS aggregation_date
    , CAST(user_id AS bigint)             AS user_id
    , CAST(report_period AS string)       AS report_period
    , CAST(unit AS bigint)                AS unit
    , CAST(date_range AS int)             AS date_range
    , CAST(audited_report_id AS bigint)   AS audited_report_id
    , CAST(sc_firm_filter AS string)      AS sc_firm_filter
    , CAST(record_status AS int)          AS record_status
    , CAST(sql_query AS string)           AS sql_query
    , CAST(export_format AS string)       AS export_format
    , CAST(report_type AS bigint)         AS report_type
    , CAST(description AS string)         AS description
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_by AS bigint)    AS last_modified_by
    , CAST(created_by AS bigint)          AS created_by
    , CAST(report_group_id AS bigint)     AS report_group_id
    , CAST(template_file_path AS string)  AS template_file_path
    , CAST(report_name AS string)         AS report_name
    , CAST(parameter AS string)           AS parameter
    , CAST(sort_order AS bigint)          AS sort_order
FROM {{ source('source_scms', 'raw_output_report_extraction') }}