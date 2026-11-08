/*
*--------------------------------------------------------------------*
* Program code: stg_scms_scms_working_day
* Program name: Staging SCMS.SCMS_WORKING_DAY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (1 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: calendar_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(calendar_date AS date) AS calendar_date
    , CAST(working_day AS int)    AS working_day
FROM {{ source('source_scms', 'raw_scms_working_day') }}