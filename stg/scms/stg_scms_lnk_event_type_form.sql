/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_event_type_form
* Program name: Staging SCMS.LNK_EVENT_TYPE_FORM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (1 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (2 cot).
* 2026-11-03		tuan.nguyenvanb		Chinh kieu theo ket qua profiling du lieu nguon SCMS_NEW: timestamp sang date: applicable_from, applicable_to.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))             AS id
    , CAST(event_type_id AS decimal(19,0))  AS event_type_id
    , CAST(form_report_id AS decimal(19,0)) AS form_report_id
    , CAST(applicable_from AS date)    AS applicable_from
    , CAST(applicable_to AS date)      AS applicable_to
    , CAST(required AS int)                 AS required
    , CAST(sort_order AS bigint)            AS sort_order
    , CAST(record_status AS int)            AS record_status
FROM {{ source('source_scms', 'raw_lnk_event_type_form') }}