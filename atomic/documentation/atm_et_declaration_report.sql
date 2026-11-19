/*
*--------------------------------------------------------------------*
* Program code: atm_et_declaration_report
* Program name: Atomic Et Declaration Report
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Tao model theo lld_KNT_TAX_REPORT.yaml (Fact Append -> incremental_rebase append). UAT chua co model KNT nao.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        service_code
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
    FROM {{ ref('ods_knt_tax_report') }}
)

SELECT
    {{ generate_surrogate_key_bigint('KNT_TAX_REPORT', "src.declaration_code") }}    AS et_declaration_rpt_id
    , CAST(src.declaration_code AS string)                                             AS et_declaration_rpt_code
    , CAST('KNT_TAX_REPORT' AS string)                                                 AS src_stm_code
    , {{ generate_surrogate_key_bigint('KNT_TAX_REGISTRATION_INFO', "src.tax_code") }} AS et_registration_id
    , CAST(src.tax_code AS string)                                                     AS et_registration_code
    , CAST(src.service_code AS string)                                                 AS service_code
    , CAST(src.service_name AS string)                                                 AS service_nm
    , CAST(src.service_version AS string)                                              AS service_version
    , CAST(src.service_provider_info AS string)                                        AS service_provider_information
    , CAST(src.declaration_name AS string)                                             AS declaration_nm
    , CAST(src.form_description AS string)                                             AS form_description
    , CAST(src.declaration_xml_version AS string)                                      AS declaration_xml_version
    , CAST(src.declaration_type AS string)                                             AS declaration_tp_code
    , CAST(src.attempt_count AS int)                                                   AS attempt_count
    , CAST(src.period_type AS string)                                                  AS period_tp_code
    , CAST(src.declaration_period AS string)                                           AS declaration_period
    , CAST(src.declaration_from_date AS string)                                        AS declaration_from_dt
    , CAST(src.declaration_to_date AS string)                                          AS declaration_to_dt
    , CAST(src.declaration_from_month AS string)                                       AS declaration_from_month
    , CAST(src.declaration_to_month AS string)                                         AS declaration_to_month
    , CAST(src.tax_office_code AS string)                                              AS tax_office_code
    , CAST(src.tax_office_name AS string)                                              AS tax_office_nm
    , CAST(src.declaration_date AS string)                                             AS declaration_dt
    , CAST(src.extension_reason_code AS string)                                        AS extension_reason_code
    , CAST(src.extension_reason AS string)                                             AS extension_reason_description
    , CAST(src.signatory AS string)                                                    AS signatory_full_nm
    , CAST(src.signed_at AS date)                                                      AS signed_dt
    , CAST(src.business_line AS string)                                                AS business_line_nm
    , CAST(src.representative_name AS string)                                          AS representative_full_nm
    , CAST(src.taxpayer_address AS string)                                             AS taxpayer_adr
    , CAST(src.ward AS string)                                                         AS taxpayer_ward_nm
    , CAST(src.taxpayer_district_code AS string)                                       AS taxpayer_district_code
    , CAST(src.taxpayer_district_name AS string)                                       AS taxpayer_district_nm
    , CAST(src.taxpayer_province_code AS string)                                       AS taxpayer_province_code
    , CAST(src.taxpayer_province_name AS string)                                       AS taxpayer_province_nm
    , CAST(src.taxpayer_phone AS string)                                               AS taxpayer_phone_nbr
    , CAST(src.taxpayer_fax AS string)                                                 AS taxpayer_fax_nbr
    , CAST(src.taxpayer_email AS string)                                               AS taxpayer_email
    , CAST(src.audit_status_text AS string)                                            AS audit_status_description
    , CAST(src.audit_firm_tax_code AS string)                                          AS af_tax_code
    , CAST(src.audit_firm_name AS string)                                              AS af_nm
    , CAST(src.auditor_code AS string)                                                 AS auditor_code
    , CAST(src.auditor_name AS string)                                                 AS auditor_full_nm
    , CAST(src.audited AS string)                                                      AS audited_flag
    , CAST(src.audit_opinion_code AS string)                                           AS audit_opinion_code
    , CAST(src.audit_opinion AS string)                                                AS audit_opinion_description
    , CAST(src.audit_date AS date)                                                     AS audit_dt
    , CAST(src.created_at AS timestamp)                                                AS created_tms
    , CAST(src.add_info_submission_date AS date)                                       AS additional_info_submission_dt
    , CAST(src.add_info_received_date AS date)                                         AS additional_info_received_dt
    , CAST(src.add_info_preparation_period AS string)                                  AS additional_info_preparation_period
    , CAST(src.add_info_source AS string)                                              AS additional_info_src
    , CAST(src.add_info_entered_by AS string)                                          AS additional_info_entered_by_nm
    , CAST(src.add_info_received_at AS date)                                           AS additional_info_received_at_dt
    , CAST(src.add_info_declaration_id AS string)                                      AS additional_info_declaration_id
    , CAST(src.add_info_sent_from AS string)                                           AS additional_info_sent_from_nm
    , CAST(src.add_info_received_at_location AS string)                                AS additional_info_received_at_location
    , CAST(src.guid AS string)                                                         AS global_unique_identifier
    , CAST(src.msg_packet_id AS string)                                                AS message_packet_id
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')                                   AS data_dt
FROM src
