/*
*--------------------------------------------------------------------*
* Program code: ods_ecat_department
* Program name: ODS ECAT.DEPARTMENT
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
    , code
    , name
    , parent_id
    , description
    , phone
    , email
    , active
    , active_reason
    , deleted
    , deleted_reason
    , version
    , effective_start_date
    , effective_end_date
    , old_id
    , created_at
    , updated_at
    , created_by_id
    , created_by_name
    , updated_by_id
    , updated_by_name
    , stable_id
    , parent_version_id
    , sort_order
    , effective
    , type
FROM {{ ref('stg_ecat_department') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')