/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_disclosure_report
* Program name: Staging ECAT.DISCLOSURE_REPORT
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
    , CAST(code AS string)                    AS code
    , CAST(name AS string)                    AS name
    , CAST(report_type AS int)                AS report_type
    , CAST(report_period AS int)              AS report_period
    , CAST(applied_subject AS int)            AS applied_subject
    , CAST(form_legal_basis AS string)        AS form_legal_basis
    , CAST(submission_time AS string)         AS submission_time
    , CAST(disclosure_deadline AS string)     AS disclosure_deadline
    , CAST(report_status AS int)              AS report_status
    , CAST(deleted AS int)                    AS deleted
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(stable_id AS string)               AS stable_id
    , CAST(version AS int)                    AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
FROM {{ source('source_ecat', 'raw_disclosure_report') }}