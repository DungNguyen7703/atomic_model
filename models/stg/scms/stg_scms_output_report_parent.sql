/*
*--------------------------------------------------------------------*
* Program code: stg_scms_output_report_parent
* Program name: Staging SCMS.OUTPUT_REPORT_PARENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))         AS id
    , CAST(report_code AS string)       AS report_code
    , CAST(report_name AS string)       AS report_name
    , CAST(sender_entity AS string)     AS sender_entity
    , CAST(report_group AS string)      AS report_group
    , CAST(description AS string)       AS description
    , CAST(note AS string)              AS note
    , CAST(legal_basis AS string)       AS legal_basis
    , CAST(excel_export_type AS int)    AS excel_export_type
    , CAST(record_status AS int)        AS record_status
    , CAST(sort_order AS bigint)        AS sort_order
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(created_by AS decimal(19,0)) AS created_by
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(updated_by AS decimal(19,0)) AS updated_by
FROM {{ source('source_scms', 'raw_output_report_parent') }}