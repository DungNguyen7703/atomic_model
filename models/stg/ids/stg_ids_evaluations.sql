/*
*--------------------------------------------------------------------*
* Program code: stg_ids_evaluations
* Program name: Staging IDS.EVALUATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(company_id AS int)           AS company_id
    , CAST(period_id AS int)            AS period_id
    , CAST(total_score AS decimal(5,2)) AS total_score
    , CAST(evaluation_date AS date)     AS evaluation_date
    , CAST(type AS string)              AS type
    , CAST(status AS string)            AS status
    , CAST(approved_by AS string)       AS approved_by
    , CAST(approved_date AS date)       AS approved_date
    , CAST(created_by AS string)        AS created_by
    , CAST(created_date AS date)        AS created_date
    , CAST(updated_by AS string)        AS updated_by
    , CAST(updated_date AS date)        AS updated_date
FROM {{ source('source_ids', 'raw_evaluations') }}