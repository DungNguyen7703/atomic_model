/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_licensed_practitioner
* Program name: ODS SCMS.SC_FIRM_LICENSED_PRACTITIONER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		tra		Them dieu kien loc ban ghi con hieu luc (theo ods_filters.pdf): deleted = 0 AND record_status = 1
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sc_firm_info_id
    , sc_firm_personnel_id
    , securities_license_number
    , securities_license_date
    , synced
    , sync_at
    , note
    , created_by
    , created_at
    , record_status
    , sc_firm_service_id
    , full_name_legacy
    , date_of_birth
    , national_id_legacy
    , id_card_issued_date
    , issue_place_legacy
    , nationality_legacy
    , permanent_address_legacy
    , permanent_residence
    , birth_place
    , phone_legacy
    , mobile
    , email
    , company_name
    , english_name
    , short_name
    , license_number
    , department_legacy
    , position_legacy
    , start_date
    , end_date
    , record_status_alt
    , errtext
    , report_id
    , datecreated
    , createdby
    , datemodify
    , modifyby
    , batchid
    , content
    , nhn_id
    , deleted
    , gender_legacy
    , sc_firm_branch_id
    , sc_firm_transaction_office_id
    , sc_firm_rep_office_id
    , business_line_id
    , labor_contract_termination_report
    , business_division_id
    , national_id
    , position_ids
    , permanent_address
    , responsible_service_id
    , phone
    , entity_type
    , attachment_path
    , gender
    , full_name
    , insider
    , work_start_date
    , appointment_date
    , issue_date
    , last_modified_at
    , work_end_date
    , dismissal_date
    , date_of_birth_alt
    , last_modified_by
    , issue_place
    , department
    , nationality_id
    , securities_license_number_alt
    , latest_verification_at
    , work_status
    , verification_status
    , mismatch_reason
FROM {{ ref('stg_scms_sc_firm_licensed_practitioner') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
  AND record_status = 1