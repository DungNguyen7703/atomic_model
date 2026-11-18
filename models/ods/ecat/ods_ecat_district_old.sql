/*
*--------------------------------------------------------------------*
* Program code: ods_ecat_district_old
* Program name: ODS ECAT.DISTRICT_OLD
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
    , province_old_id
    , display_label
    , active
    , active_reason
    , deleted
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
    , province_old_version_id
    , deleted_reason
    , effective
    , id_sync
FROM {{ ref('stg_ecat_district_old') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')