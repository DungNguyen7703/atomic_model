/*
*--------------------------------------------------------------------*
* Program code: atm_inspection_annual_plan
* Program name: Atomic Inspection Annual Plan
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH in_an_pl AS (
    SELECT
        id
        , name
        , plan_year
        , decision_number
        , decision_date
        , status
        , note
    FROM {{ ref('ods_thanhtra_inspection_annual_plan') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_ANNUAL_PLAN', "in_an_pl.id") }} AS inspection_annual_plan_id
    , CAST(in_an_pl.id AS string)                                                         AS inspection_annual_plan_code
    , CAST('THANHTRA_INSPECTION_ANNUAL_PLAN' AS string)                                   AS src_stm_code
    , CAST(in_an_pl.name AS string)                                                       AS inspection_annual_plan_nm
    , CAST(in_an_pl.plan_year AS int)                                                     AS plan_year
    , CAST(in_an_pl.decision_number AS string)                                            AS approval_decision_nbr
    , CAST(in_an_pl.decision_date AS date)                                                AS approval_decision_dt
    , CAST(in_an_pl.status AS string)                                                     AS life_cycle_status_code
    , CAST(in_an_pl.note AS string)                                                       AS note
FROM in_an_pl