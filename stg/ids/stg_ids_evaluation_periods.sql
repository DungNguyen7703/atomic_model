/*
*--------------------------------------------------------------------*
* Program code: stg_ids_evaluation_periods
* Program name: Staging IDS.EVALUATION_PERIODS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)               AS id
    , CAST(year AS string)        AS year
    , CAST(month AS string)       AS month
    , CAST(description AS string) AS description
    , CAST(status AS string)      AS status
    , CAST(created_by AS string)  AS created_by
    , CAST(created_date AS date)  AS created_date
    , CAST(updated_by AS string)  AS updated_by
    , CAST(updated_date AS date)  AS updated_date
FROM {{ source('source_ids', 'raw_evaluation_periods') }}