/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_rep_office
* Program name: ODS SCMS.SC_FIRM_REP_OFFICE
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
    , sc_firm_branch_id
    , full_name
    , address
    , province_id
    , district_name
    , ward_name
    , phone
    , fax
    , decision_number_alt
    , decision_date_alt
    , valid_dossier_date
    , representative_name
    , rep_office_status
    , note
    , created_by
    , created_at
    , last_modified_by
    , last_modified_at
    , record_status
    , provisional
    , sc_firm_rep_office_id
    , district_id
    , ward_id
    , representative_id
    , decision_date
    , decision_number
    , office_name
    , attachment_path
    , official_operation_date
    , scope_of_operation
    , event_type_id
    , document_declaration
    , document_number
    , document_date
    , validity_start_date
    , validity_end_date
    , document_file_path
    , form_data_json
    , deleted
FROM {{ ref('stg_scms_sc_firm_rep_office') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')