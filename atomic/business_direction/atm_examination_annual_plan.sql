/*
*--------------------------------------------------------------------*
* Program code: atm_examination_annual_plan
* Program name: Atomic Examination Annual Plan
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ex_an_pl AS (
    SELECT
        id
        , name
        , plan_year
        , decision_number
        , decision_date
        , status
        , note
    FROM {{ ref('ods_thanhtra_examination_annual_plan') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_ANNUAL_PLAN', "ex_an_pl.id") }} AS examination_annual_plan_id
    , CAST(ex_an_pl.id AS string)                                                          AS examination_annual_plan_code
    , CAST('THANHTRA_EXAMINATION_ANNUAL_PLAN' AS string)                                   AS src_stm_code
    , CAST(ex_an_pl.name AS string)                                                        AS examination_annual_plan_nm
    , CAST(ex_an_pl.plan_year AS int)                                                      AS plan_year
    , CAST(ex_an_pl.decision_number AS string)                                             AS approval_decision_nbr
    , CAST(ex_an_pl.decision_date AS date)                                                 AS approval_decision_dt
    , CAST(ex_an_pl.status AS string)                                                      AS life_cycle_status_code
    , CAST(ex_an_pl.note AS string)                                                        AS note
FROM ex_an_pl