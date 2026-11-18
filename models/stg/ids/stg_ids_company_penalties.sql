/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_penalties
* Program name: Staging IDS.COMPANY_PENALTIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                             AS id
    , CAST(company_profile_id AS int)           AS company_profile_id
    , CAST(penalized_subject_type_cd AS string) AS penalized_subject_type_cd
    , CAST(investor_name AS string)             AS investor_name
    , CAST(investor_id_no AS string)            AS investor_id_no
    , CAST(investor_id_issue_date AS date)      AS investor_id_issue_date
    , CAST(investor_address AS string)          AS investor_address
    , CAST(position_cd AS string)               AS position_cd
    , CAST(penalty_decision_no AS string)       AS penalty_decision_no
    , CAST(penalty_decision_date AS date)       AS penalty_decision_date
    , CAST(violation_desc AS string)            AS violation_desc
    , CAST(penalty_form AS string)              AS penalty_form
    , CAST(penalty_amount AS int)               AS penalty_amount
    , CAST(additional_penalty AS string)        AS additional_penalty
    , CAST(remedial_minutes AS string)          AS remedial_minutes
    , CAST(created_by AS string)                AS created_by
    , CAST(created_date AS date)                AS created_date
    , CAST(updated_by AS string)                AS updated_by
    , CAST(updated_date AS date)                AS updated_date
    , CAST(delete_flg AS int)                   AS delete_flg
FROM {{ source('source_ids', 'raw_company_penalties') }}