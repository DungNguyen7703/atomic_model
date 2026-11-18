/*
*--------------------------------------------------------------------*
* Program code: stg_fms_job_tl_pro
* Program name: Staging FMS.JOB_TL_PRO
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(job_id)            AS job_id
    , HEX(tlpro_id)        AS tlpro_id
    , CAST(is_main AS int) AS is_main
FROM {{ source('source_fms', 'raw_job_tl_pro') }}