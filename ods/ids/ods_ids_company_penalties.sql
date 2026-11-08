/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_penalties
* Program name: ODS IDS.COMPANY_PENALTIES
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
    , company_profile_id
    , penalized_subject_type_cd
    , investor_name
    , investor_id_no
    , investor_id_issue_date
    , investor_address
    , position_cd
    , penalty_decision_no
    , penalty_decision_date
    , violation_desc
    , penalty_form
    , penalty_amount
    , additional_penalty
    , remedial_minutes
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_ids_company_penalties') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')