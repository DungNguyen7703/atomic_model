/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_violation_behavior_legal_document
* Program name: Staging THANHTRA.VIOLATION_BEHAVIOR_LEGAL_DOCUMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(violation_behavior_id AS string) AS violation_behavior_id
    , CAST(legal_document_id AS string)     AS legal_document_id
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(created_by AS string)            AS created_by
    , CAST(last_modified_at AS timestamp)   AS last_modified_at
    , CAST(last_modified_by AS string)      AS last_modified_by
    , CAST(version AS bigint)               AS version
    , CAST(deleted AS int)                  AS deleted
FROM {{ source('source_thanhtra', 'raw_violation_behavior_legal_document') }}