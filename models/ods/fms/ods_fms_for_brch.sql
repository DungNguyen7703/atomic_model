/*
*--------------------------------------------------------------------*
* Program code: ods_fms_for_brch
* Program name: ODS FMS.FOR_BRCH
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
    , status_id
    , nat_id
    , branch_flag
    , item_name
    , en_name
    , short_name
    , address
    , license
    , license_date
    , phone
    , fax
    , email
    , website
    , start_date
    , end_date
    , parent_name
    , parent_code
    , parent_address
    , change_license
    , change_license_date
    , change_note
    , file_data
    , note
    , deleted
    , reg_no
    , tax_code
    , capital
    , data_migration
    , id_db_old
    , event_type_id
    , parent_issue_place
    , parent_issue_date
    , activity_period
    , province_id
    , ward_id
FROM {{ ref('stg_fms_for_brch') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0