/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rpt_member_tester_purge
* Program name: Staging FIMS.RPT_MEMBER_TESTER_PURGE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		tuan.nguyenvanb		[MOI] Bo sung STG theo FIMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,0))            AS id
    , CAST(rpt_member_id AS decimal(18,0)) AS rpt_member_id
    , CAST(status_snapshot AS int)         AS status_snapshot
    , CAST(purged AS int)                  AS purged
    , CAST(purged_at AS timestamp)         AS purged_at
    , CAST(restored_at AS timestamp)       AS restored_at
    , CAST(date_created AS timestamp)      AS date_created
    , CAST(date_modified AS timestamp)     AS date_modified
    , CAST(created_by AS string)           AS created_by
    , CAST(modify_by AS string)            AS modify_by
FROM {{ source('source_fims', 'raw_rpt_member_tester_purge') }}