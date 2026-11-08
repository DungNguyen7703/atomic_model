/*
*--------------------------------------------------------------------*
* Program code: ods_fms_insider
* Program name: ODS FMS.INSIDER
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
    , sc_id
    , nat_id
    , s_id
    , tlpro_id
    , item_name
    , id_no
    , id_date
    , id_add
    , insider_no
    , tl_profile_linked
    , tl_profile_in_sec
    , insider_type
    , capital
    , qtty
    , reprecent
    , per_date
    , record_status
    , description
    , address
    , telephone
    , fax
    , email
    , deleted
    , data_migration
    , birth
    , s_work_dte
    , employ_status
    , gp_qd_no
    , approval_date
FROM {{ ref('stg_fms_insider') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')