/*
*--------------------------------------------------------------------*
* Program code: ods_ecat_province_new
* Program name: ODS ECAT.PROVINCE_NEW
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
    , name_vn
    , name_en
    , region_id
    , country_id
    , effective
    , display_label
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
    , region_version_id
    , country_version_id
    , id_sync
FROM {{ ref('stg_ecat_province_new') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')