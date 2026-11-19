/*
*--------------------------------------------------------------------*
* Program code: ods_knt_tax_registration_info
* Program name: ODS KNT.TAX_REGISTRATION_INFO
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
    , msg_packet_id
    , taxpayer_name
    , tax_code
    , hq_address
    , phone
    , fax
    , charter_capital
    , business_line
    , license_number
    , issue_date
    , issuing_authority
    , decision_number
    , issued_date
    , issuing_org
    , supervising_unit
    , business_start_date
    , legal_representative_name
    , id_card_number
    , so_dien_thoai
    , director_name
    , director_phone
    , operation_status
    , suspension_reason
    , suspension_type
    , direct_supervising_authority
    , tax_authority_code
    , domestic_capital_currency
    , foreign_capital_amount
    , foreign_capital_currency
    , supervising_unit_address
    , business_address_desc
    , business_province_code
    , business_district_code
    , business_ward_code
    , business_phone
    , business_email
    , business_fax
    , suspension_from_date
    , suspension_to_date
    , suspension_reason_text
    , suspension_notice_number
    , suspension_notice_date
    , operation_stop_date
    , operation_stop_reason
    , operation_stop_note
    , operation_stop_notice_number
    , status_name
    , business_line_code
    , business_province_name
    , business_district_name
    , business_ward_name
    , foreign_capital_ratio
FROM {{ ref('stg_knt_tax_registration_info') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')