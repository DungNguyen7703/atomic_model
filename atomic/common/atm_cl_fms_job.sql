/*
*--------------------------------------------------------------------*
* Program code: atm_cl_fms_job
* Program name: Atomic Classification FMS Job
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khoi tao theo LLD Atomic FMS UAT 20261006 (lld_FMS_JOBS.yaml + lld_FMS_JOB_TYPE.yaml)
*										Gop JOB_TYPE vao cung entity: denormalize job_tp_nm qua JOBS.JOB_TYPE_ID = JOB_TYPE.ID
*										(theo FMS_HLD_Tier1 sua 2026-10-02) - 1 dong / JOBS
*--------------------------------------------------------------------*
*/

WITH jobs AS (
    SELECT
        id
        , item_name
        , job_type_id
    FROM {{ ref('ods_fms_jobs') }}
),

job_ty AS (
    SELECT
        id
        , item_name
    FROM {{ ref('ods_fms_job_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_JOBS', "jobs.id") }}             AS cl_fms_job_id
    , CAST(jobs.id AS string)                                              AS cl_fms_job_code
    , CAST('FMS_JOBS' AS string)                                           AS src_stm_code
    , CAST(jobs.item_name AS string)                                       AS cl_fms_job_nm
    , {{ generate_surrogate_key_bigint('FMS_JOB_TYPE', "jobs.job_type_id") }} AS cl_fms_job_tp_id
    , CAST(jobs.job_type_id AS string)                                     AS cl_fms_job_tp_code
    , CAST(job_ty.item_name AS string)                                     AS job_tp_nm
FROM jobs
    LEFT JOIN job_ty ON jobs.job_type_id = job_ty.id