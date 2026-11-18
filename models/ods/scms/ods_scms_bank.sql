/*
*--------------------------------------------------------------------*
* Program code: ods_scms_bank
* Program name: ODS SCMS.BANK
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
    , address
    , phone
    , email
    , enterprise_code
    , tax_code
    , created_at
    , created_by
    , bank_name
    , record_status
    , last_modified_by
    , last_modified_at
    , name_en
    , short_name
    , fax
    , website
    , operation_license_number
    , license_issue_date
    , license_issuer
    , charter_capital
    , category
    , settlement_bank_decision_number
    , settlement_bank_decision_date
    , settlement_start_date
    , settlement_function_description
    , business_reg_cert_number
    , business_reg_cert_date
    , custodian_start_date
    , custodian_member_cert_number
    , custodian_cert_date
    , custodian_member_code
    , custodian_function_description
    , attachment_path
    , note
    , input_report_data
    , eform_data_json
    , deleted
FROM {{ ref('stg_scms_bank') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')