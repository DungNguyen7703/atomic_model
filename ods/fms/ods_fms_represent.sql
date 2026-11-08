/*
*--------------------------------------------------------------------*
* Program code: ods_fms_represent
* Program name: ODS FMS.REPRESENT
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
    , job_id
    , nat_id
    , fund_id
    , item_name
    , id_no
    , id_date
    , province
    , position
    , record_status
    , address
    , email
    , tel
    , fax
    , deleted
    , education
    , prof_qualifi
    , other_exp
    , other_position
    , description
    , member_type
    , data_migration
    , origin_id
FROM {{ ref('stg_fms_represent') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')