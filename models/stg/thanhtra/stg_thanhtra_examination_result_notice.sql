/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_examination_result_notice
* Program name: Staging THANHTRA.EXAMINATION_RESULT_NOTICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(examination_team_id AS string)   AS examination_team_id
    , CAST(notice_number AS string)         AS notice_number
    , CAST(issued_date AS date)             AS issued_date
    , CAST(announced_date AS date)          AS announced_date
    , CAST(target_type AS string)           AS target_type
    , CAST(target_reference_id AS string)   AS target_reference_id
    , CAST(target_name AS string)           AS target_name
    , CAST(content AS string)               AS content
    , CAST(recommendation AS string)        AS recommendation
    , CAST(execution_status AS string)      AS execution_status
    , CAST(execution_description AS string) AS execution_description
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(last_modified_at AS timestamp)   AS last_modified_at
    , CAST(created_by AS string)            AS created_by
    , CAST(last_modified_by AS string)      AS last_modified_by
    , CAST(version AS bigint)               AS version
    , CAST(deleted AS int)                  AS deleted
FROM {{ source('source_thanhtra', 'raw_examination_result_notice') }}