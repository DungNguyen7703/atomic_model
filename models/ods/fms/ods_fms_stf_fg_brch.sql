/*
*--------------------------------------------------------------------*
* Program code: ods_fms_stf_fg_brch
* Program name: ODS FMS.STF_FG_BRCH
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
    , for_brch_id
    , jobs_id
    , nat_id
    , staff_branch
    , item_name
    , sex
    , address
    , record_status
    , id_code
    , date_code
    , issued_code
    , email
    , represent
    , license
    , license_date
    , file_data
    , note
    , deleted
    , created_by
    , date_created
    , date_modified
    , modify_by
    , isp
    , pl_email
    , data_migration
    , practice_cert_no
    , practice_cert_issue_date
    , branch_director
    , director_appoint_license_no
    , director_approval_date
    , license_end_date
FROM {{ ref('stg_fms_stf_fg_brch') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')