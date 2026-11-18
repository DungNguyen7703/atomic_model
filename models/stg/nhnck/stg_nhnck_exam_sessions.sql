/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_exam_sessions
* Program name: Staging NHNCK.EXAM_SESSIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (8 cot); kieu date sang timestamp (2 cot); them cot result_updater_id; doi thu tu cot.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                       AS id
    , CAST(name AS string)                   AS name
    , CAST(code AS string)                   AS code
    , CAST(year AS bigint)                   AS year
    , CAST(session_ AS bigint)               AS session_
    , CAST(organizing_unit AS string)        AS organizing_unit
    , CAST(application_start_date AS string) AS application_start_date
    , CAST(application_end_date AS string)   AS application_end_date
    , CAST(exam_start_date AS string)        AS exam_start_date
    , CAST(exam_end_date AS string)          AS exam_end_date
    , CAST(file_path AS string)              AS file_path
    , CAST(noti_date AS string)              AS noti_date
    , CAST(exam_locations AS string)         AS exam_locations
    , CAST(submission_methods AS string)     AS submission_methods
    , CAST(status AS bigint)                 AS status
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(updated_at AS timestamp)          AS updated_at
    , CAST(created_by AS bigint)             AS created_by
    , CAST(updated_by AS bigint)             AS updated_by
    , CAST(decision_id AS bigint)            AS decision_id
    , CAST(bank_id AS bigint)                AS bank_id
    , CAST(bank_account_number AS string)    AS bank_account_number
    , CAST(bank_account_name AS string)      AS bank_account_name
    , CAST(result_updater_id AS bigint)      AS result_updater_id
FROM {{ source('source_nhnck', 'raw_exam_sessions') }}