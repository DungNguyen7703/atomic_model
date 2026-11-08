/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_violation_case_received_document
* Program name: Staging THANHTRA.VIOLATION_CASE_RECEIVED_DOCUMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                       AS id
    , CAST(violation_case_id AS string)      AS violation_case_id
    , CAST(document_number AS string)        AS document_number
    , CAST(document_date AS date)            AS document_date
    , CAST(issuing_unit_name AS string)      AS issuing_unit_name
    , CAST(violation_subject_name AS string) AS violation_subject_name
    , CAST(violation_record_id AS string)    AS violation_record_id
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(created_by AS string)             AS created_by
    , CAST(last_modified_by AS string)       AS last_modified_by
    , CAST(version AS bigint)                AS version
    , CAST(deleted AS int)                   AS deleted
    , CAST(issuing_unit_id AS string)        AS issuing_unit_id
FROM {{ source('source_thanhtra', 'raw_violation_case_received_document') }}