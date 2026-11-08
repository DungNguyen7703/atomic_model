/*
*--------------------------------------------------------------------*
* Program code: stg_fms_job_stf_fg_brch
* Program name: Staging FMS.JOB_STF_FG_BRCH
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(job_id)          AS job_id
    , HEX(stf_fg_brch_id)  AS stf_fg_brch_id
    , CAST(is_main AS int) AS is_main
FROM {{ source('source_fms', 'raw_job_stf_fg_brch') }}