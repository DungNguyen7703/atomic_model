/*
*--------------------------------------------------------------------*
* Program code: stg_scms_scms_shedlock
* Program name: Staging SCMS.SCMS_SHEDLOCK
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(name AS string)          AS name
    , CAST(lock_until AS timestamp) AS lock_until
    , CAST(locked_at AS timestamp)  AS locked_at
    , CAST(locked_by AS string)     AS locked_by
FROM {{ source('source_scms', 'raw_scms_shedlock') }}