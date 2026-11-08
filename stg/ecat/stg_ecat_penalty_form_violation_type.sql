/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_penalty_form_violation_type
* Program name: Staging ECAT.PENALTY_FORM_VIOLATION_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(penalty_form_id AS string)            AS penalty_form_id
    , CAST(penalty_form_stable_id AS string)   AS penalty_form_stable_id
    , CAST(violation_type_id AS string)        AS violation_type_id
    , CAST(violation_type_stable_id AS string) AS violation_type_stable_id
FROM {{ source('source_ecat', 'raw_penalty_form_violation_type') }}