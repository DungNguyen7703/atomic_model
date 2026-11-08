/*
*--------------------------------------------------------------------*
* Program code: stg_fms_inspection_round
* Program name: Staging FMS.INSPECTION_ROUND
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                  AS id
    , CAST(deleted AS int)                   AS deleted
    , CAST(object_type AS decimal(38,0))     AS object_type
    , CAST(other_object_name AS string)      AS other_object_name
    , CAST(inspection_year AS decimal(38,0)) AS inspection_year
    , CAST(start_date AS date)               AS start_date
    , CAST(end_date AS date)                 AS end_date
    , CAST(decision_no AS string)            AS decision_no
    , CAST(decision_date AS date)            AS decision_date
    , CAST(period_from AS date)              AS period_from
    , CAST(period_to AS date)                AS period_to
    , CAST(inspection_kind AS decimal(38,0)) AS inspection_kind
    , CAST(date_created AS timestamp)        AS date_created
    , CAST(created_by AS string)             AS created_by
    , CAST(date_modified AS timestamp)       AS date_modified
    , CAST(modify_by AS string)              AS modify_by
FROM {{ source('source_fms', 'raw_inspection_round') }}