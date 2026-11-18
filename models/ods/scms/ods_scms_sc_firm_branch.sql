/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_branch
* Program name: ODS SCMS.SC_FIRM_BRANCH
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
    , sc_firm_info_id
    , full_name
    , address
    , province_id
    , district_name
    , ward_name
    , phone
    , fax
    , decision_number
    , decision_date
    , valid_dossier_date
    , director_name
    , business_lines
    , branch_status
    , note
    , created_by
    , created_at
    , last_modified_by
    , last_modified_at
    , record_status
    , provisional
    , sc_firm_branch_id
    , district_id
    , ward_id
    , director_personnel_id
    , representative_title
    , issuing_authority
    , email
    , branch_code
    , license_date
    , operation_date
    , last_modified_at_legacy
    , representative_name
    , last_modified_by_legacy
    , phone_number
    , license_number
    , branch_name
    , name_en
    , website
    , attachment_path
    , official_operation_date
    , branch_allocated_capital
    , matter_id
    , form_data_json
    , deleted
    , director_nationality_id
    , director_date_of_birth
    , director_id_number
    , director_id_issue_date
    , director_id_issue_place
    , director_license_number
    , director_license_date
FROM {{ ref('stg_scms_sc_firm_branch') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')