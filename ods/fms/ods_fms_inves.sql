/*
*--------------------------------------------------------------------*
* Program code: ods_fms_inves
* Program name: ODS FMS.INVES
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
    , sec_id
    , nat_id
    , sto_id
    , item_name
    , id_type
    , id_no
    , id_place
    , id_date
    , dorf
    , address
    , relation_ship
    , deleted
    , ad_scale
    , act_scale
    , list_value
    , data_migration
FROM {{ ref('stg_fms_inves') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')