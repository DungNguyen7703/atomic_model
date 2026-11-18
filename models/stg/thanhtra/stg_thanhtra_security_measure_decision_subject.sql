/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_security_measure_decision_subject
* Program name: Staging THANHTRA.SECURITY_MEASURE_DECISION_SUBJECT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(security_measure_decision_id AS string) AS security_measure_decision_id
    , CAST(subject_type AS string)                 AS subject_type
    , CAST(subject_name AS string)                 AS subject_name
    , CAST(subject_id_number AS string)            AS subject_id_number
    , CAST(subject_dob AS date)                    AS subject_dob
    , CAST(subject_address AS string)              AS subject_address
    , CAST(subject_legal_rep AS string)            AS subject_legal_rep
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(last_modified_at AS timestamp)          AS last_modified_at
    , CAST(created_by AS string)                   AS created_by
    , CAST(last_modified_by AS string)             AS last_modified_by
    , CAST(version AS bigint)                      AS version
    , CAST(deleted AS int)                         AS deleted
FROM {{ source('source_thanhtra', 'raw_security_measure_decision_subject') }}