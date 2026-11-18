/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_transaction_office
* Program name: ODS SCMS.SC_FIRM_TRANSACTION_OFFICE
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
    , decision_number
    , decision_date
    , valid_dossier_date
    , representative_name
    , transaction_office_status
    , note
    , created_by
    , created_at
    , last_modified_by_alt
    , last_modified_at_alt
    , record_status
    , provisional
    , sc_firm_transaction_id
    , district_id
    , ward_id
    , representative_id
    , document_declaration
    , event_type_id
    , attachment_path
    , document_file_path
    , official_operation_date
    , validity_end_date
    , validity_start_date
    , decision_date_alt
    , document_date
    , decision_number_alt
    , document_number
    , transaction_office_name
    , form_data_json
    , last_modified_at
    , last_modified_by
    , deleted
FROM {{ ref('stg_scms_sc_firm_transaction_office') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')