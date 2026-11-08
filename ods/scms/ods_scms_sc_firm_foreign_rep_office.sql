/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_foreign_rep_office
* Program name: ODS SCMS.SC_FIRM_FOREIGN_REP_OFFICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Dong bo day du cot theo stg moi.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , amendment_declaration
    , address
    , amendment_document_file
    , enterprise_code
    , tax_code
    , license_date
    , amendment_effective_date
    , official_operation_date
    , created_at
    , country
    , license_number
    , amendment_document_number
    , parent_company_name
    , rep_office_name
    , record_status
    , sc_firm_info_id
    , parent_company_license
    , parent_license_date
    , parent_hq_address
    , phone
    , fax
    , email
    , operation_term_years
    , expiry_date
    , scope_json
    , attachment_path
    , note
    , rep_office_status_id
    , event_type_id
    , reporting_enabled
    , admin_proc_data
    , created_by
    , last_modified_by
    , last_modified_at
    , form_data_json
    , deleted
FROM {{ ref('stg_scms_sc_firm_foreign_rep_office') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')