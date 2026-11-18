/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_violation_behavior_penalty_form
* Program name: Staging ECAT.VIOLATION_BEHAVIOR_PENALTY_FORM
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(violation_behavior_id AS string)          AS violation_behavior_id
    , CAST(violation_behavior_stable_id AS string) AS violation_behavior_stable_id
    , CAST(penalty_form_id AS string)              AS penalty_form_id
    , CAST(penalty_form_stable_id AS string)       AS penalty_form_stable_id
FROM {{ source('source_ecat', 'raw_violation_behavior_penalty_form') }}