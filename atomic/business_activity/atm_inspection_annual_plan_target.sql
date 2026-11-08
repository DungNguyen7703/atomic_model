/*
*--------------------------------------------------------------------*
* Program code: atm_inspection_annual_plan_target
* Program name: Atomic Inspection Annual Plan Target
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH in_an_pl_ta AS (
    SELECT
        id
        , inspection_annual_plan_id
        , target_type
        , target_reference_id
        , target_name
        , target_code
        , target_source
        , planned_quarter
        , planned_content
    FROM {{ ref('ods_thanhtra_inspection_annual_plan_target') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_ANNUAL_PLAN_TARGET', "in_an_pl_ta.id") }}                   AS inspection_annual_plan_target_id
    , CAST(in_an_pl_ta.id AS string)                                                                                  AS inspection_annual_plan_target_code
    , CAST('THANHTRA_INSPECTION_ANNUAL_PLAN_TARGET' AS string)                                                        AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_ANNUAL_PLAN', "in_an_pl_ta.inspection_annual_plan_id") }} AS inspection_annual_plan_id
    , CAST(in_an_pl_ta.inspection_annual_plan_id AS string)                                                           AS inspection_annual_plan_code
    , CAST(in_an_pl_ta.target_type AS string)                                                                         AS target_tp_code
    , CAST(in_an_pl_ta.target_reference_id AS string)                                                                 AS target_reference_id
    , CAST(in_an_pl_ta.target_name AS string)                                                                         AS target_nm
    , CAST(in_an_pl_ta.target_code AS string)                                                                         AS target_code
    , CAST(in_an_pl_ta.target_source AS string)                                                                       AS target_src
    , CAST(in_an_pl_ta.planned_quarter AS int)                                                                        AS planned_quarter
    , CAST(in_an_pl_ta.planned_content AS string)                                                                     AS planned_content
FROM in_an_pl_ta