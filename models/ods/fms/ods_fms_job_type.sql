/*
*--------------------------------------------------------------------*
* Program code: ods_fms_job_type
* Program name: ODS FMS.JOB_TYPE
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khởi tạo — nguồn cho Atomic FMS (sync LLD Atomic FMS UAT 20261006)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , item_name
    , record_status
    , display_on_member_profile
    , published
    , deleted
FROM {{ ref('stg_fms_job_type') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
    AND record_status = 1