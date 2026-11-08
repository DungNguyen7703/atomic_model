/*
*--------------------------------------------------------------------*
* Program code: ods_fms_ward
* Program name: ODS FMS.WARD
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
    , category
    , effective
    , display_label
    , active
    , province_id
    , province_code
    , province_name_vn
    , deleted
    , last_synced_at
    , date_created
    , created_by
    , date_modified
    , modify_by
FROM {{ ref('stg_fms_ward') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0  
