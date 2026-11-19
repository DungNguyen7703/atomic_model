/*
*--------------------------------------------------------------------*
* Program code: ods_knt_tax_report
* Program name: ODS KNT.TAX_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-11-12		ngoc.pham		Bo cot data_dt khoi SELECT cho khop DDL (Truncate then Insert)
*--------------------------------------------------------------------*
*/

SELECT
    id
    , service_code
    , service_name
    , service_version
    , service_provider_info
    , declaration_code
    , declaration_name
    , form_description
    , declaration_xml_version
    , declaration_type
    , attempt_count
    , period_type
    , declaration_period
    , declaration_from_date
    , declaration_to_date
    , declaration_from_month
    , declaration_to_month
    , tax_office_code
    , tax_office_name
    , declaration_date
    , extension_reason_code
    , extension_reason
    , signatory
    , signed_at
    , business_line
    , tax_code
    , representative_name
    , taxpayer_address
    , ward
    , taxpayer_district_code
    , taxpayer_district_name
    , taxpayer_province_code
    , taxpayer_province_name
    , taxpayer_phone
    , taxpayer_fax
    , taxpayer_email
    , audit_status_text
    , audit_firm_tax_code
    , audit_firm_name
    , auditor_code
    , auditor_name
    , audited
    , audit_opinion_code
    , audit_opinion
    , audit_date
    , created_at
    , msg_packet_id
    , add_info_submission_date
    , add_info_received_date
    , add_info_preparation_period
    , add_info_source
    , add_info_entered_by
    , add_info_received_at
    , add_info_declaration_id
    , add_info_sent_from
    , add_info_received_at_location
    , guid
    , is_latest
    , has_diff
    , peer_report_id
    , dc_ready
FROM {{ ref('stg_knt_tax_report') }}