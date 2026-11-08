/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_examination_annual_plan
* Program name: Staging THANHTRA.EXAMINATION_ANNUAL_PLAN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(name AS string)             AS name
    , CAST(plan_year AS int)           AS plan_year
    , CAST(decision_number AS string)  AS decision_number
    , CAST(decision_date AS date)      AS decision_date
    , CAST(status AS string)           AS status
    , CAST(note AS string)             AS note
    , CAST(created_at AS date)         AS created_at
    , CAST(last_modified_at AS date)   AS last_modified_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(version AS bigint)          AS version
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_thanhtra', 'raw_examination_annual_plan') }}