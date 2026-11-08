/*
*--------------------------------------------------------------------*
* Program code: stg_fms_ftor_scale
* Program name: Staging FMS.FTOR_SCALE
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
    , CAST(date_created AS date)             AS date_created
    , CAST(created_by AS string)             AS created_by
    , CAST(date_modified AS date)            AS date_modified
    , CAST(modify_by AS string)              AS modify_by
    , HEX(ftor_id)                           AS ftor_id
    , CAST(grading_method AS int)            AS grading_method
    , CAST(based_grading AS int)             AS based_grading
    , CAST(from_value AS decimal(38,0))      AS from_value
    , CAST(from_value_condition AS bigint)   AS from_value_condition
    , CAST(to_value AS decimal(38,0))        AS to_value
    , CAST(to_value_condition AS bigint)     AS to_value_condition
    , CAST(ranking_value AS bigint)          AS ranking_value
    , CAST(max_minus_point AS decimal(38,0)) AS max_minus_point
    , CAST(record_status AS int)             AS record_status
    , CAST(note AS string)                   AS note
FROM {{ source('source_fms', 'raw_ftor_scale') }}