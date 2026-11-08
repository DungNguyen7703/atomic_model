/*
*--------------------------------------------------------------------*
* Program code: stg_knt_tax_report
* Program name: Staging KNT.TAX_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                               AS id
    , CAST(service_code AS string)                  AS service_code
    , CAST(service_name AS string)                  AS service_name
    , CAST(service_version AS string)               AS service_version
    , CAST(service_provider_info AS string)         AS service_provider_info
    , CAST(declaration_code AS string)              AS declaration_code
    , CAST(declaration_name AS string)              AS declaration_name
    , CAST(form_description AS string)              AS form_description
    , CAST(declaration_xml_version AS string)       AS declaration_xml_version
    , CAST(declaration_type AS string)              AS declaration_type
    , CAST(attempt_count AS int)                    AS attempt_count
    , CAST(period_type AS string)                   AS period_type
    , CAST(declaration_period AS string)            AS declaration_period
    , CAST(declaration_from_date AS string)         AS declaration_from_date
    , CAST(declaration_to_date AS string)           AS declaration_to_date
    , CAST(declaration_from_month AS string)        AS declaration_from_month
    , CAST(declaration_to_month AS string)          AS declaration_to_month
    , CAST(tax_office_code AS string)               AS tax_office_code
    , CAST(tax_office_name AS string)               AS tax_office_name
    , CAST(declaration_date AS string)              AS declaration_date
    , CAST(extension_reason_code AS string)         AS extension_reason_code
    , CAST(extension_reason AS string)              AS extension_reason
    , CAST(signatory AS string)                     AS signatory
    , CAST(signed_at AS date)                       AS signed_at
    , CAST(business_line AS string)                 AS business_line
    , CAST(tax_code AS string)                      AS tax_code
    , CAST(representative_name AS string)           AS representative_name
    , CAST(taxpayer_address AS string)              AS taxpayer_address
    , CAST(ward AS string)                          AS ward
    , CAST(taxpayer_district_code AS string)        AS taxpayer_district_code
    , CAST(taxpayer_district_name AS string)        AS taxpayer_district_name
    , CAST(taxpayer_province_code AS string)        AS taxpayer_province_code
    , CAST(taxpayer_province_name AS string)        AS taxpayer_province_name
    , CAST(taxpayer_phone AS string)                AS taxpayer_phone
    , CAST(taxpayer_fax AS string)                  AS taxpayer_fax
    , CAST(taxpayer_email AS string)                AS taxpayer_email
    , CAST(audit_status_text AS string)             AS audit_status_text
    , CAST(audit_firm_tax_code AS string)           AS audit_firm_tax_code
    , CAST(audit_firm_name AS string)               AS audit_firm_name
    , CAST(auditor_code AS string)                  AS auditor_code
    , CAST(auditor_name AS string)                  AS auditor_name
    , CAST(audited AS string)                       AS audited
    , CAST(audit_opinion_code AS string)            AS audit_opinion_code
    , CAST(audit_opinion AS string)                 AS audit_opinion
    , CAST(audit_date AS date)                      AS audit_date
    , CAST(created_at AS int)                       AS created_at
    , CAST(msg_packet_id AS int)                    AS msg_packet_id
    , CAST(add_info_submission_date AS date)        AS add_info_submission_date
    , CAST(add_info_received_date AS date)          AS add_info_received_date
    , CAST(add_info_preparation_period AS string)   AS add_info_preparation_period
    , CAST(add_info_source AS string)               AS add_info_source
    , CAST(add_info_entered_by AS string)           AS add_info_entered_by
    , CAST(add_info_received_at AS date)            AS add_info_received_at
    , CAST(add_info_declaration_id AS string)       AS add_info_declaration_id
    , CAST(add_info_sent_from AS string)            AS add_info_sent_from
    , CAST(add_info_received_at_location AS string) AS add_info_received_at_location
    , CAST(guid AS string)                          AS guid
    , CAST(is_latest AS int)                        AS is_latest
    , CAST(has_diff AS int)                         AS has_diff
    , CAST(peer_report_id AS int)                   AS peer_report_id
    , CAST(dc_ready AS int)                         AS dc_ready
FROM {{ source('source_knt', 'raw_tax_report') }}