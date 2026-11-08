/*
*--------------------------------------------------------------------*
* Program code: ods_scms_disclosure_securities_offering
* Program name: ODS SCMS.DISCLOSURE_SECURITIES_OFFERING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-04		Claude				offering_method: đổi nguồn từ cột offering_method sang parse plan_json[0].loaiChaoBan
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sc_firm_info_id
    , document_number
    , document_date
    , valid_date
    , offering_date
    , end_date
    , get_json_object(plan_json, '$[0].loaiChaoBan') AS offering_method
    , target_investors
    , quantity
    , item_value
    , note
    , disclosure_person_name
    , disclosure_date
    , attachment_path
    , error_description
    , created_by
    , created_at
    , last_modified_by_legacy
    , last_modified_at_legacy
    , sent_at
    , record_status
    , matter
    , legacy_filename
    , legacy_filedata
    , legacy_rowtext
    , event_type_id
    , expected_end_date
    , expected_start_date
    , synced_from_admin_proc
    , result_attachment_path
    , document_file_path
    , offering_price
    , result_json
    , offering_type
    , securities_type
    , offering_purpose
    , result_report_date
    , start_date
    , offering_start_date
    , offering_end_date
    , last_modified_at
    , last_modified_by
    , data_source
    , plan_json
    , capital_use_plan
    , offered_quantity
    , underwriter
    , advisor
    , total_value
    , total_offered_quantity
    , total_offered_completed
    , expected_total_amount
    , proceeds_collected
    , admin_proc_id
    , extension_to_date
    , assessment
    , underwriting_company
    , capital_use_result_json
    , item_category
    , bond_type
    , bond_face_value
    , bond_code
    , maturity_years
    , interest_payment_period
    , bond_holder_representative
    , collateral_required
    , issuance_date
    , covered_warrant_type
    , covered_warrant_name
    , listed_cw_code
    , underlying_securities_code
    , underlying_securities_issuer
    , first_dossier_submission_date
    , complete_dossier_submission_date
    , cw_registered_quantity
    , conversion_ratio
    , converted_shares_quantity
    , registered_offering_price
    , cw_term_months
    , collateral_settlement_value
    , collateral_deposit_bank
    , cw_permitted_quantity
    , cw_shares_per_warrant
    , cw_distributed_quantity
    , cw_actual_offering_price
    , cw_offering_date
    , cw_maturity_date
    , cw_deposit_amount
    , cw_proceeds
FROM {{ ref('stg_scms_disclosure_securities_offering') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')