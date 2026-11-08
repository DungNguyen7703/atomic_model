/*
*--------------------------------------------------------------------*
* Program code: atm_pc_evaluation_period
* Program name: Atomic Public Company Evaluation Period
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ev_pe AS (
    SELECT
        id
        , year
        , month
        , description
        , status
    FROM {{ ref('ods_ids_evaluation_periods') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_EVALUATION_PERIODS', "ev_pe.id") }} AS pc_evaluation_period_id
    , CAST(ev_pe.id AS string)                                                AS pc_evaluation_period_code
    , CAST('IDS_EVALUATION_PERIODS' AS string)                                AS src_stm_code
    , CAST(ev_pe.year AS string)                                              AS evaluation_year
    , CAST(ev_pe.month AS string)                                             AS evaluation_month
    , CAST(ev_pe.description AS string)                                       AS description
    , CAST(ev_pe.status AS string)                                            AS evaluation_period_status_code
FROM ev_pe