/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_foreign_branch
* Program name: ODS SCMS.SC_FIRM_FOREIGN_BRANCH
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
    , sc_firm_info_id
    , address
    , parent_company_address
    , phone
    , event_type_id
    , synced_from_admin_proc
    , email
    , fax
    , amendment_document_file
    , business_reg_cert
    , note
    , financial_report_type
    , enterprise_code
    , tax_code
    , business_reg_cert_date
    , last_modified_at
    , license_date
    , parent_company_license_date
    , amendment_effective_date
    , official_operation_date
    , fiscal_year_end_date
    , created_at
    , last_modified_by
    , created_by
    , country
    , license_number
    , parent_company_license_number
    , amendment_document_number
    , branch_name
    , parent_company_name
    , name_en
    , short_name
    , record_status
    , allocated_capital
    , attachment_path
    , form_data_json
    , deleted
FROM {{ ref('stg_scms_sc_firm_foreign_branch') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')