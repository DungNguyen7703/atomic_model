/*
*--------------------------------------------------------------------*
* Program code: stg_ids_evaluation_details
* Program name: Staging IDS.EVALUATION_DETAILS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)              AS id
    , CAST(evaluation_id AS int) AS evaluation_id
    , CAST(criterion_id AS int)  AS criterion_id
    , CAST(result AS string)     AS result
    , CAST(score AS int)         AS score
    , CAST(evaluate AS int)      AS evaluate
    , CAST(created_by AS string) AS created_by
    , CAST(created_date AS date) AS created_date
    , CAST(updated_by AS string) AS updated_by
    , CAST(updated_date AS date) AS updated_date
FROM {{ source('source_ids', 'raw_evaluation_details') }}