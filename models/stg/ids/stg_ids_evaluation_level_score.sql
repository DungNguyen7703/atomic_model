/*
*--------------------------------------------------------------------*
* Program code: stg_ids_evaluation_level_score
* Program name: Staging IDS.EVALUATION_LEVEL_SCORE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(evaluate AS int)       AS evaluate
    , CAST(score AS decimal(5,2)) AS score
    , CAST(description AS string) AS description
    , CAST(created_by AS string)  AS created_by
    , CAST(created_date AS date)  AS created_date
    , CAST(updated_by AS string)  AS updated_by
    , CAST(updated_date AS date)  AS updated_date
FROM {{ source('source_ids', 'raw_evaluation_level_score') }}