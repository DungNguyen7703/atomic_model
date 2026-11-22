/*
*--------------------------------------------------------------------*
* Program code: atm_pc_penalty
* Program name: Atomic Pc Penalty
* Created by:
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
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
    FROM {{ ref('ods_ids_company_penalties') }}
    WHERE created_date >= TO_TIMESTAMP('{{ var("etl_date") }}')
        AND created_date < TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_PENALTIES', "id") }}                  AS pc_penalty_id
    , CAST(id AS string)                                                                AS pc_penalty_code
    , CAST('IDS_COMPANY_PENALTIES' AS string)                                           AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(penalized_subject_type_cd AS string)                                         AS penalized_subject_tp_code
    , CAST(investor_name AS string)                                                     AS investor_nm
    , CAST(investor_id_no AS string)                                                    AS investor_identification_nbr
    , CAST(investor_id_issue_date AS date)                                              AS investor_identification_issue_dt
    , CAST(investor_address AS string)                                                  AS investor_adr
    , CAST(position_cd AS string)                                                       AS investor_position_code
    , CAST(penalty_decision_no AS string)                                               AS pd_nbr
    , CAST(penalty_decision_date AS date)                                               AS pd_dt
    , CAST(violation_desc AS string)                                                    AS violation_description
    , CAST(penalty_form AS string)                                                      AS penalty_form_description
    , CAST(penalty_amount AS decimal(23,2))                                             AS penalty_amt
    , CAST(additional_penalty AS string)                                                AS additional_penalty_description
    , CAST(remedial_minutes AS string)                                                  AS remedial_minutes_description
FROM src
