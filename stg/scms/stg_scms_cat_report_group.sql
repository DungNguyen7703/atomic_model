/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_report_group
* Program name: Staging SCMS.CAT_REPORT_GROUP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))         AS id
    , CAST(code AS string)              AS code
    , CAST(name AS string)              AS name
    , CAST(description AS string)       AS description
    , CAST(sort_order AS int)           AS sort_order
    , CAST(record_status AS int)        AS record_status
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(created_by AS decimal(19,0)) AS created_by
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(updated_by AS decimal(19,0)) AS updated_by
    , CAST(report_kind AS string)       AS report_kind
FROM {{ source('source_scms', 'raw_cat_report_group') }}