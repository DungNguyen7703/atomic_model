/*
*--------------------------------------------------------------------*
* Program code: stg_fms_inspection_standalone_penalty
* Program name: Staging FMS.INSPECTION_STANDALONE_PENALTY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                 AS id
    , HEX(target_id)                          AS target_id
    , CAST(external_id AS string)             AS external_id
    , CAST(penalty_decision_no AS string)     AS penalty_decision_no
    , CAST(penalty_decision_date AS date)     AS penalty_decision_date
    , CAST(violation_behavior AS string)      AS violation_behavior
    , CAST(legal_basis AS string)             AS legal_basis
    , CAST(penalty_form AS string)            AS penalty_form
    , CAST(penalty_amount AS decimal(38,0))   AS penalty_amount
    , CAST(additional_penalty_form AS string) AS additional_penalty_form
    , CAST(remedy_measure AS string)          AS remedy_measure
    , CAST(execution_status AS string)        AS execution_status
    , CAST(remedy_status AS string)           AS remedy_status
    , CAST(data_source AS string)             AS data_source
    , CAST(deleted AS int)                    AS deleted
    , CAST(date_created AS timestamp)         AS date_created
    , CAST(created_by AS string)              AS created_by
    , CAST(date_modified AS timestamp)        AS date_modified
    , CAST(modify_by AS string)               AS modify_by
FROM {{ source('source_fms', 'raw_inspection_standalone_penalty') }}