/*
*--------------------------------------------------------------------*
* Program code: stg_tms_analysis_account_relationship
* Program name: Staging TMS.ANALYSIS_ACCOUNT_RELATIONSHIP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo UAT_TMS_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                  AS id
    , CAST(case_file_id AS string)        AS case_file_id
    , CAST(workflow_type AS int)          AS workflow_type
    , CAST(result_type AS int)            AS result_type
    , CAST(relationship_id AS string)     AS relationship_id
    , CAST(analysis_date AS timestamp)    AS analysis_date
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(updated_at AS timestamp)       AS updated_at
    , CAST(created_by_id AS string)       AS created_by_id
    , CAST(updated_by_id AS string)       AS updated_by_id
    , CAST(created_by_name AS string)     AS created_by_name
    , CAST(updated_by_name AS string)     AS updated_by_name
    , CAST(version AS int)                AS version
    , CAST(deleted AS int)                AS deleted
    , CAST(relationship_value AS string)  AS relationship_value
    , CAST(account_code_1 AS string)      AS account_code_1
    , CAST(account_code_2 AS string)      AS account_code_2
    , CAST(securities_code_id AS string)  AS securities_code_id
    , CAST(securities_code AS string)     AS securities_code
    , CAST(workflow_id AS string)         AS workflow_id
    , CAST(source_account_code AS string) AS source_account_code
FROM {{ source('source_tms', 'raw_analysis_account_relationship') }}