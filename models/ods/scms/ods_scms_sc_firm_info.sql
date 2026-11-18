/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_info
* Program name: ODS SCMS.SC_FIRM_INFO
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
    , sc_firm_info_id
    , code
    , short_name
    , name_vi
    , name_en
    , address
    , province_id
    , district_name
    , ward_name
    , country_id
    , phone
    , fax
    , email
    , website
    , charter_capital
    , tax_code
    , business_license_number
    , business_license_date
    , business_license_issuer
    , company_type_id
    , total_shares
    , business_lines
    , listed
    , listing_exchange
    , securities_code
    , sc_firm_registration_date
    , decision_number
    , license_expiry_date
    , termination_decision_number
    , created_by
    , created_at
    , last_modified_by
    , last_modified_at
    , record_status
    , provisional
    , enterprise_code
    , electronic_trading_status
    , electronic_trading_decision_number
    , electronic_trading_decision_date
    , electronic_trading_reason
    , note
    , attachment_path
    , additional_business_lines
    , district_id
    , ward_id
    , certificate_number
    , listing_date
    , custodian_cert_number
    , custodian_cert_date
    , public_company_registration_date
    , public_company_decision_number
    , synced_from_admin_proc
    , amendment_declaration
    , amendment_document_number
    , amendment_effective_date
    , amendment_document_file
    , public_company
    , event_type_id
    , foundation_license_file
    , ownership_limit_to_date
    , ownership_limit_from_date
    , foreign_investor_ownership_limit
    , business_license
    , financial_report_type
    , custodian_member_code
    , custodian_member_cert_date
    , foundation_license_date
    , official_operation_date
    , amendment_expiry_date
    , public_company_end_date
    , fiscal_year_end_date
    , amendment_document_date
    , foundation_license_issuer
    , custodian_member_cert_number
    , foundation_license_number
    , public_company_end_decision_number
    , form_data_json
    , custodian_membership_revocation_decision
    , custodian_membership_revocation_date
    , last_modified_by_alt
    , trading_registered
    , custody_reg_cert_decision_number
    , custody_reg_cert_decision_date
    , deleted
    , business_reg_cert_number
    , business_reg_cert_date
    , business_reg_cert_issuer
FROM {{ ref('stg_scms_sc_firm_info') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')