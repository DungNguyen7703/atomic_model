/*
*--------------------------------------------------------------------*
* Program code: ods_ids_securities_offering
* Program name: ODS IDS.SECURITIES_OFFERING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date    User    Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , applicant_type_flg
    , company_profile_id
    , legal_entity_id
    , application_cd
    , administrative_proc_cd
    , administrative_status_cd
    , certificate_no
    , certificate_date
    , official_letter_no
    , official_letter_date
    , offering_purpose
    , total_registered_qty
    , total_expected_am
    , capital_usage_plan
    , expected_schedule
    , matching_capital
    , consulting_org
    , audit_org
    , bond_representative_org
    , underwwriting_org
    , credit_rating_org
    , other_org
    , approval_status_cd
    , approver_user_id
    , approver_user_name
    , processor_user_id
    , processor_user_name
    , revision_reason
    , multi_turn_flg
    , is_sync
    , delete_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , submission_date
    , project_investment_flg
    , capital_purpose
    , approver_comment
FROM {{ ref('stg_ids_securities_offering') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')