/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_alert
* Program name: Staging SCMS.CAT_ALERT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (5 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (4 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: start_date, end_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(form_report_id AS bigint)  AS form_report_id
    , CAST(form_sheet_cell_id AS bigint) AS form_sheet_cell_id
    , CAST(alert_code AS string)      AS alert_code
    , CAST(alert_name AS string)      AS alert_name
    , CAST(formula AS string)         AS formula
    , CAST(condition AS string)       AS condition
    , CAST(item_value AS string)      AS item_value
    , CAST(hierarchy_level AS int)    AS hierarchy_level
    , CAST(description AS string)     AS description
    , CAST(start_date AS date)      AS start_date
    , CAST(end_date AS date)        AS end_date
    , CAST(created_at AS timestamp)      AS created_at
    , CAST(created_by AS bigint)      AS created_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(last_modified_by AS bigint) AS last_modified_by
    , CAST(deleted AS int)            AS deleted
    , CAST(record_status AS int)      AS record_status
FROM {{ source('source_scms', 'raw_cat_alert') }}