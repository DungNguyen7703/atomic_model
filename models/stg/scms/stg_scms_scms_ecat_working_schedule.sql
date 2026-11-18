/*
*--------------------------------------------------------------------*
* Program code: stg_scms_scms_ecat_working_schedule
* Program name: Staging SCMS.SCMS_ECAT_WORKING_SCHEDULE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (2 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: tu_ngay, den_ngay.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(ecat_id AS string)         AS ecat_id
    , CAST(code AS string)            AS code
    , CAST(name AS string)            AS name
    , CAST(description AS string)     AS description
    , CAST(schedule_type AS string)   AS schedule_type
    , CAST(tu_ngay AS date)      AS tu_ngay
    , CAST(den_ngay AS date)     AS den_ngay
    , CAST(ecat_sync_at AS timestamp) AS ecat_sync_at
FROM {{ source('source_scms', 'raw_scms_ecat_working_schedule') }}