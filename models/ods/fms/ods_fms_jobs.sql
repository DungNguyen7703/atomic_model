/*
*--------------------------------------------------------------------*
* Program code: ods_fms_jobs
* Program name: ODS FMS.JOBS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , item_name
    , job_type_id
    , record_status
    , system_object
    , deleted
    , data_migration
FROM {{ ref('stg_fms_jobs') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')