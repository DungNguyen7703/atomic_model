/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_alert_resolution_file
* Program name: Staging MRMS.RISK_ALERT_RESOLUTION_FILE
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
    , CAST(resolution_id AS string)    AS resolution_id
    , CAST(file_name AS string)        AS file_name
    , CAST(file_path AS string)        AS file_path
    , CAST(file_size AS decimal(19,0)) AS file_size
    , CAST(file_type AS string)        AS file_type
    , CAST(uploaded_at AS timestamp)   AS uploaded_at
    , CAST(uploaded_by_id AS string)   AS uploaded_by_id
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(updated_at AS timestamp)    AS updated_at
    , CAST(created_by_id AS string)    AS created_by_id
    , CAST(updated_by_id AS string)    AS updated_by_id
    , CAST(created_by_name AS string)  AS created_by_name
    , CAST(updated_by_name AS string)  AS updated_by_name
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_mrms', 'raw_risk_alert_resolution_file') }}