/*
*--------------------------------------------------------------------*
* Program code: atm_inspection_team
* Program name: Atomic Inspection Team
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH in_te AS (
    SELECT
        code
        , inspection_annual_plan_id
        , plan_year
        , form_type
        , start_date
        , end_date
        , duration_days
        , decision_number
        , decision_date
        , decision_name
        , announcement_date
        , inspection_period_from
        , inspection_period_to
        , anti_money_laundering
        , abnormal_transaction_check
        , verification_minutes_sign_date
        , criminal_transfer
        , criminal_transfer_note
    FROM {{ ref('ods_thanhtra_inspection_team') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_TEAM', "in_te.code") }}                               AS inspection_team_id
    , CAST(in_te.code AS string)                                                                                AS inspection_team_code
    , CAST('THANHTRA_INSPECTION_TEAM' AS string)                                                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_ANNUAL_PLAN', "in_te.inspection_annual_plan_id") }} AS inspection_annual_plan_id
    , CAST(in_te.inspection_annual_plan_id AS string)                                                           AS inspection_annual_plan_code
    , CAST(in_te.plan_year AS int)                                                                              AS plan_year
    , CAST(in_te.form_type AS string)                                                                           AS form_tp_code
    , CAST(in_te.start_date AS date)                                                                            AS start_dt
    , CAST(in_te.end_date AS date)                                                                              AS end_dt
    , CAST(in_te.duration_days AS int)                                                                          AS duration_days
    , CAST(in_te.decision_number AS string)                                                                     AS decision_nbr
    , CAST(in_te.decision_date AS date)                                                                         AS decision_dt
    , CAST(in_te.decision_name AS string)                                                                       AS decision_nm
    , CAST(in_te.announcement_date AS date)                                                                     AS announcement_dt
    , CAST(in_te.inspection_period_from AS date)                                                                AS inspection_period_from_dt
    , CAST(in_te.inspection_period_to AS date)                                                                  AS inspection_period_to_dt
    , CAST(in_te.anti_money_laundering AS int)                                                                  AS anti_money_laundering_ind
    , CAST(in_te.abnormal_transaction_check AS int)                                                             AS abnormal_transaction_check_ind
    , CAST(in_te.verification_minutes_sign_date AS date)                                                        AS verification_minutes_sign_dt
    , CAST(in_te.criminal_transfer AS int)                                                                      AS criminal_transfer_ind
    , CAST(in_te.criminal_transfer_note AS string)                                                              AS criminal_transfer_note
FROM in_te