/*
*--------------------------------------------------------------------*
* Program code: atm_examination_annual_plan_target
* Program name: Atomic Examination Annual Plan Target
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ex_an_pl_ta AS (
    SELECT
        id
        , examination_annual_plan_id
        , target_type
        , target_reference_id
        , target_name
        , leading_unit_name
        , planned_content
        , planned_quarter
    FROM {{ ref('ods_thanhtra_examination_annual_plan_target') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_ANNUAL_PLAN_TARGET', "ex_an_pl_ta.id") }}                    AS examination_annual_plan_target_id
    , CAST(ex_an_pl_ta.id AS string)                                                                                    AS examination_annual_plan_target_code
    , CAST('THANHTRA_EXAMINATION_ANNUAL_PLAN_TARGET' AS string)                                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_ANNUAL_PLAN', "ex_an_pl_ta.examination_annual_plan_id") }} AS examination_annual_plan_id
    , CAST(ex_an_pl_ta.examination_annual_plan_id AS string)                                                            AS examination_annual_plan_code
    , CAST(ex_an_pl_ta.target_type AS string)                                                                           AS target_tp_code
    , CAST(ex_an_pl_ta.target_reference_id AS string)                                                                   AS target_reference_id
    , CAST(ex_an_pl_ta.target_name AS string)                                                                           AS target_nm
    , CAST(ex_an_pl_ta.leading_unit_name AS string)                                                                     AS leading_unit_nm
    , CAST(ex_an_pl_ta.planned_content AS string)                                                                       AS planned_content
    , CAST(ex_an_pl_ta.planned_quarter AS int)                                                                          AS planned_quarter
FROM ex_an_pl_ta