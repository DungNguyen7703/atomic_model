/*
*--------------------------------------------------------------------*
* Program code: stg_scms_report_violation
* Program name: Staging SCMS.REPORT_VIOLATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (3 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (2 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: violation_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)             AS id
    , CAST(sc_firm_info_id AS bigint) AS sc_firm_info_id
    , CAST(reason AS string)         AS reason
    , CAST(violation_date AS date) AS violation_date
    , CAST(user_id AS bigint)        AS user_id
    , CAST(last_modified_at AS timestamp) AS last_modified_at
FROM {{ source('source_scms', 'raw_report_violation') }}