/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_report_periodic
* Program name: Staging SCMS.FORM_REPORT_PERIODIC
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (4 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot); WHERE loc theo cot expected_insert_date trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: expected_insert_date.
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (expected_insert_date) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(expected_insert_date,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(form_report_id AS bigint)      AS form_report_id
    , CAST(report_period AS string)       AS report_period
    , CAST(period_num AS int)             AS period_num
    , CAST(latest_submission_time AS int) AS latest_submission_time
    , CAST(unit AS int)                   AS unit
    , CAST(preparation_time AS int)       AS preparation_time
    , CAST(submission_hour AS int)        AS submission_hour
    , CAST(expected_insert_date AS date) AS expected_insert_date
    , CAST(active AS int)                 AS active
    , CAST(record_status AS int)          AS record_status
    , CAST(note AS string)                AS note
    , CAST(created_by AS bigint)          AS created_by
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(on_day AS int)                 AS on_day
    , CAST(insert_value AS string)        AS insert_value
    , CAST(prev_form_periodic_id AS bigint) AS prev_form_periodic_id
    , CAST(legacy_report_id AS string)    AS legacy_report_id
FROM {{ source('source_scms', 'raw_form_report_periodic') }}
WHERE date_format(expected_insert_date, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(expected_insert_date, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1