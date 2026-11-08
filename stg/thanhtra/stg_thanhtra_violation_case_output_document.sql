/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_violation_case_output_document
* Program name: Staging THANHTRA.VIOLATION_CASE_OUTPUT_DOCUMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(violation_case_id AS string)   AS violation_case_id
    , CAST(document_type AS string)       AS document_type
    , CAST(document_number AS string)     AS document_number
    , CAST(document_name AS string)       AS document_name
    , CAST(document_date AS date)         AS document_date
    , CAST(penalty_decision_id AS string) AS penalty_decision_id
    , CAST(note AS string)                AS note
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS bigint)             AS version
    , CAST(deleted AS int)                AS deleted
FROM {{ source('source_thanhtra', 'raw_violation_case_output_document') }}