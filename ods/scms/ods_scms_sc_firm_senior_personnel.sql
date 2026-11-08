/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_senior_personnel
* Program name: ODS SCMS.SC_FIRM_SENIOR_PERSONNEL
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
    , sc_firm_info_id
    , sc_firm_branch_id
    , sc_firm_transaction_office_id
    , sc_firm_rep_office_id
    , department
    , position_id
    , full_name
    , personnel_status
    , id_number
    , issue_date
    , issue_place
    , date_of_birth
    , gender
    , nationality_id_legacy
    , place_of_birth
    , address
    , phone
    , fax
    , email
    , disclosure_email
    , shareholder_type
    , work_start_date
    , resignation_date
    , note
    , report_content
    , created_by
    , created_at
    , last_modified_by
    , last_modified_at
    , record_status
    , provisional
    , practice_certificate
    , disclosure_person_id
    , attachment_path
    , legal_representative
    , deleted
    , practitioner_legacy_id
    , disclosure_person_id_alt
    , business_division_id
    , national_id
    , position
    , position_ids
    , securities_license
    , statutory_representative
    , responsible_service_id
    , entity_type
    , start_date
    , appointment_date
    , securities_license_date
    , end_date
    , dismissal_date
    , nationality_id
    , securities_license_number
    , contributed_capital
    , ownership_ratio_date
    , disclosure_effective_date
    , disclosure_authorization_doc_number
    , ownership_ratio
    , sync_source
FROM {{ ref('stg_scms_sc_firm_senior_personnel') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')