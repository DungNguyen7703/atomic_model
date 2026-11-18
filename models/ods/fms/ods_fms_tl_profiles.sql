/*
*--------------------------------------------------------------------*
* Program code: ods_fms_tl_profiles
* Program name: ODS FMS.TL_PROFILES
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
    , branch_id
    , nat_id
    , item_name
    , sex
    , id_no
    , id_date
    , qtty
    , record_status
    , id_add
    , description
    , cust_type
    , jobfr_date
    , jobclose_date
    , cert_no
    , cert_date
    , address
    , telephone
    , fax
    , email
    , deleted
    , short_name
    , isr
    , isp
    , current_add
    , education
    , qualyfication
    , job_type
    , politics
    , birth
    , place_of_birth
    , cert_type
    , isd
    , isi
    , host_office
    , file_name
    , file_data
    , record_type
    , mov_date
    , add_work
    , employed
    , posit_job
    , time_work
    , profession
    , cdy_acc
    , pl_email
    , swork_dte
    , fwork_dte
    , fn_type
    , department
    , cell_phone
    , certified
    , insder_id
    , busi_id
    , confirm_status
    , data_migration
    , event_type_id
    , edit_reason
    , event_payload
FROM {{ ref('stg_fms_tl_profiles') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    AND deleted = 0 
    AND record_status = 1