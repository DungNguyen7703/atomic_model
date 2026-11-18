/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_shareholder
* Program name: ODS SCMS.SC_FIRM_SHAREHOLDER
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
    , shareholder_name
    , individual
    , date_of_birth
    , place_of_birth
    , id_number
    , issue_date
    , issue_place
    , nationality_id
    , current_address
    , household_registration
    , party_member
    , education_level
    , occupation
    , degree
    , legal_entity_representative
    , workplace
    , job_title
    , company_employee
    , trading_account
    , shareholder_type
    , shares_held
    , ownership_ratio
    , large_shareholder_date
    , note
    , created_by
    , created_at
    , last_modified_by
    , last_modified_at
    , record_status
    , sc_firm_personnel_id
    , practitioner_legacy_id
    , owner
    , founding_shareholder
    , phone
    , email
    , shareholder_entity_type
    , foreign_investment
    , contributed_capital
    , controlling_shareholder
    , freely_tradable_shares
    , pledged_shares
    , restricted_shares
    , org_short_name
    , legal_representative_name
    , representative_position
    , deleted
FROM {{ ref('stg_scms_sc_firm_shareholder') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')