/*
*--------------------------------------------------------------------*
* Program code: stg_knt_tax_registration_info
* Program name: Staging KNT.TAX_REGISTRATION_INFO
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                              AS id
    , CAST(msg_packet_id AS int)                   AS msg_packet_id
    , CAST(taxpayer_name AS string)                AS taxpayer_name
    , CAST(tax_code AS string)                     AS tax_code
    , CAST(hq_address AS string)                   AS hq_address
    , CAST(phone AS string)                        AS phone
    , CAST(fax AS string)                          AS fax
    , CAST(charter_capital AS int)                 AS charter_capital
    , CAST(business_line AS string)                AS business_line
    , CAST(license_number AS string)               AS license_number
    , CAST(issue_date AS date)                     AS issue_date
    , CAST(issuing_authority AS string)            AS issuing_authority
    , CAST(decision_number AS string)              AS decision_number
    , CAST(issued_date AS date)                    AS issued_date
    , CAST(issuing_org AS string)                  AS issuing_org
    , CAST(supervising_unit AS string)             AS supervising_unit
    , CAST(business_start_date AS date)            AS business_start_date
    , CAST(legal_representative_name AS string)    AS legal_representative_name
    , CAST(id_card_number AS string)               AS id_card_number
    , CAST(so_dien_thoai AS string)                AS so_dien_thoai
    , CAST(director_name AS string)                AS director_name
    , CAST(director_phone AS string)               AS director_phone
    , CAST(operation_status AS string)             AS operation_status
    , CAST(suspension_reason AS string)            AS suspension_reason
    , CAST(suspension_type AS string)              AS suspension_type
    , CAST(direct_supervising_authority AS string) AS direct_supervising_authority
    , CAST(tax_authority_code AS string)           AS tax_authority_code
    , CAST(domestic_capital_currency AS string)    AS domestic_capital_currency
    , CAST(foreign_capital_amount AS int)          AS foreign_capital_amount
    , CAST(foreign_capital_currency AS string)     AS foreign_capital_currency
    , CAST(supervising_unit_address AS string)     AS supervising_unit_address
    , CAST(business_address_desc AS string)        AS business_address_desc
    , CAST(business_province_code AS string)       AS business_province_code
    , CAST(business_district_code AS string)       AS business_district_code
    , CAST(business_ward_code AS string)           AS business_ward_code
    , CAST(business_phone AS string)               AS business_phone
    , CAST(business_email AS string)               AS business_email
    , CAST(business_fax AS string)                 AS business_fax
    , CAST(suspension_from_date AS date)           AS suspension_from_date
    , CAST(suspension_to_date AS date)             AS suspension_to_date
    , CAST(suspension_reason_text AS string)       AS suspension_reason_text
    , CAST(suspension_notice_number AS string)     AS suspension_notice_number
    , CAST(suspension_notice_date AS date)         AS suspension_notice_date
    , CAST(operation_stop_date AS date)            AS operation_stop_date
    , CAST(operation_stop_reason AS string)        AS operation_stop_reason
    , CAST(operation_stop_note AS string)          AS operation_stop_note
    , CAST(operation_stop_notice_number AS string) AS operation_stop_notice_number
    , CAST(status_name AS string)                  AS status_name
    , CAST(business_line_code AS string)           AS business_line_code
    , CAST(business_province_name AS string)       AS business_province_name
    , CAST(business_district_name AS string)       AS business_district_name
    , CAST(business_ward_name AS string)           AS business_ward_name
    , CAST(foreign_capital_ratio AS string)        AS foreign_capital_ratio
FROM {{ source('source_knt', 'raw_tax_registration_info') }}