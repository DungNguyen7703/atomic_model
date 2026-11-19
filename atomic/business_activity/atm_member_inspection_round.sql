/*
*--------------------------------------------------------------------*
* Program code: atm_member_inspection_round
* Program name: Atomic Member Inspection Round
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
        , object_type
        , other_object_name
        , inspection_year
        , start_date
        , end_date
        , decision_no
        , decision_date
        , period_from
        , period_to
        , inspection_kind
    FROM {{ ref('ods_fms_inspection_round') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_INSPECTION_ROUND', "id") }} AS member_inspection_round_id
    , CAST(id AS string)                                              AS member_inspection_round_code
    , CAST('FMS_INSPECTION_ROUND' AS string)                          AS src_stm_code
    , CAST(object_type AS int)                                        AS inspection_object_tp_code
    , CAST(other_object_name AS string)                               AS other_object_nm
    , CAST(inspection_year AS int)                                    AS inspection_year
    , CAST(start_date AS date)                                        AS inspection_start_dt
    , CAST(end_date AS date)                                          AS inspection_end_dt
    , CAST(decision_no AS string)                                     AS decision_nbr
    , CAST(decision_date AS date)                                     AS decision_dt
    , CAST(period_from AS date)                                       AS inspection_period_start_dt
    , CAST(period_to AS date)                                         AS inspection_period_end_dt
    , CAST(inspection_kind AS int)                                    AS inspection_kind_code
FROM src
