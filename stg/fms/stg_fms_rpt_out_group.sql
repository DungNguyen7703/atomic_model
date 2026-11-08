/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rpt_out_group
* Program name: Staging FMS.RPT_OUT_GROUP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                          AS id
    , CAST(name AS string)             AS name
    , CAST(code AS string)             AS code
    , CAST(description AS string)      AS description
    , CAST(status AS int)              AS status
    , CAST(is_deleted AS int)          AS is_deleted
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(created_by AS string)       AS created_by
    , CAST(modify_by AS string)        AS modify_by
FROM {{ source('source_fms', 'raw_rpt_out_group') }}