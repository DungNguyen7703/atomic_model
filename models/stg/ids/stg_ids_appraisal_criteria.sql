/*
*--------------------------------------------------------------------*
* Program code: stg_ids_appraisal_criteria
* Program name: Staging IDS.APPRAISAL_CRITERIA
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                 AS id
    , CAST(criteria_code AS string)   AS criteria_code
    , CAST(criteria_name AS string)   AS criteria_name
    , CAST(evaluation_rule AS string) AS evaluation_rule
    , CAST(display_order AS int)      AS display_order
    , CAST(procedure_code AS string)  AS procedure_code
    , CAST(active_flg AS int)         AS active_flg
    , CAST(criteria_type AS string)   AS criteria_type
    , CAST(created_date AS date)      AS created_date
    , CAST(created_by AS string)      AS created_by
    , CAST(updated_by AS string)      AS updated_by
    , CAST(updated_date AS date)      AS updated_date
FROM {{ source('source_ids', 'raw_appraisal_criteria') }}