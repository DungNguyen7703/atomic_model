/*
*--------------------------------------------------------------------*
* Program code: ods_fms_province
* Program name: ODS FMS.PROVINCE
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
    , effective
    , display_label
    , active
    , region_id
    , region_name
    , region_code
    , country_id
    , country_name_vn
    , country_code
    , country_display_label
    , deleted
    , last_synced_at
    , date_created
    , created_by
    , date_modified
    , modify_by
    , stable_id
FROM {{ ref('stg_fms_province') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0
