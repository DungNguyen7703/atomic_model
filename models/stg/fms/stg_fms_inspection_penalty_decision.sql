/*
*--------------------------------------------------------------------*
* Program code: stg_fms_inspection_penalty_decision
* Program name: Staging FMS.INSPECTION_PENALTY_DECISION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                   AS id
    , CAST(deleted AS int)                    AS deleted
    , HEX(inspection_round_id)                AS inspection_round_id
    , HEX(target_id)                          AS target_id
    , CAST(penalty_decision_no AS string)     AS penalty_decision_no
    , CAST(penalty_decision_date AS date)     AS penalty_decision_date
    , CAST(violation_behavior AS string)      AS violation_behavior
    , CAST(penalty_form AS string)            AS penalty_form
    , CAST(penalty_amount AS decimal(38,0))   AS penalty_amount
    , CAST(additional_penalty_form AS string) AS additional_penalty_form
    , CAST(remedy_measure AS string)          AS remedy_measure
    , CAST(execution_status AS string)        AS execution_status
    , CAST(remedy_status AS string)           AS remedy_status
    , CAST(date_created AS timestamp)         AS date_created
    , CAST(created_by AS string)              AS created_by
    , CAST(date_modified AS timestamp)        AS date_modified
    , CAST(modify_by AS string)               AS modify_by
FROM {{ source('source_fms', 'raw_inspection_penalty_decision') }}