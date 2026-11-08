/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_adhoc_anti_corruption_report
* Program name: Staging THANHTRA.ADHOC_ANTI_CORRUPTION_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(name AS string)                    AS name
    , CAST(report_type AS string)             AS report_type
    , CAST(report_year AS int)                AS report_year
    , CAST(requesting_authority AS string)    AS requesting_authority
    , CAST(request_document_number AS string) AS request_document_number
    , CAST(request_document_date AS date)     AS request_document_date
    , CAST(submission_deadline AS date)       AS submission_deadline
    , CAST(content AS string)                 AS content
    , CAST(note AS string)                    AS note
    , CAST(created_at AS date)                AS created_at
    , CAST(last_modified_at AS date)          AS last_modified_at
    , CAST(created_by AS string)              AS created_by
    , CAST(last_modified_by AS string)        AS last_modified_by
    , CAST(version AS bigint)                 AS version
    , CAST(deleted AS int)                    AS deleted
FROM {{ source('source_thanhtra', 'raw_adhoc_anti_corruption_report') }}