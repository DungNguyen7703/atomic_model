/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_report_type
* Program name: Staging MRMS.RISK_REPORT_TYPE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_MRMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(code AS string)             AS code
    , CAST(name AS string)             AS name
    , CAST(description AS string)      AS description
    , CAST(template_content AS string) AS template_content
    , CAST(display_order AS int)       AS display_order
    , CAST(is_active AS int)           AS is_active
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_mrms', 'raw_risk_report_type') }}