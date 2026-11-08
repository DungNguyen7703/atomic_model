/*
*--------------------------------------------------------------------*
* Program code: stg_scms_alert_group
* Program name: Staging SCMS.ALERT_GROUP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))               AS id
    , CAST(group_code AS string)              AS group_code
    , CAST(name AS string)                    AS name
    , CAST(description AS string)             AS description
    , CAST(sort_order AS int)                 AS sort_order
    , CAST(status AS int)                     AS status
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(created_by AS decimal(19,0))       AS created_by
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(last_modified_by AS decimal(19,0)) AS last_modified_by
FROM {{ source('source_scms', 'raw_alert_group') }}