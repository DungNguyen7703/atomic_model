/*
*--------------------------------------------------------------------*
* Program code: stg_fms_factor
* Program name: Staging FMS.FACTOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                         AS id
    , CAST(date_created AS date)    AS date_created
    , CAST(created_by AS string)    AS created_by
    , CAST(date_modified AS date)   AS date_modified
    , CAST(modify_by AS string)     AS modify_by
    , HEX(grp_ftor_id)              AS grp_ftor_id
    , HEX(parent_id)                AS parent_id
    , CAST(item_name AS string)     AS item_name
    , CAST(weight AS decimal(38,0)) AS weight
    , CAST(code AS string)          AS code
    , CAST(record_status AS int)    AS record_status
    , CAST(grading_method AS int)   AS grading_method
    , CAST(based_grading AS int)    AS based_grading
    , CAST(ranking_order AS int)    AS ranking_order
    , CAST(note AS string)          AS note
    , CAST(formula_info AS string)  AS formula_info
    , CAST(e4_factor AS int)        AS e4_factor
FROM {{ source('source_fms', 'raw_factor') }}