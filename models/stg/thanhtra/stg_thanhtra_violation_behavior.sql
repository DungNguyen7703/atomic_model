/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_violation_behavior
* Program name: Staging THANHTRA.VIOLATION_BEHAVIOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot); them cot ecatalog_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(code AS string)                    AS code
    , CAST(name AS string)                    AS name
    , CAST(description AS string)             AS description
    , CAST(primary_penalty_type_id AS string) AS primary_penalty_type_id
    , CAST(min_fine_amount AS decimal(19,4))  AS min_fine_amount
    , CAST(max_fine_amount AS decimal(19,4))  AS max_fine_amount
    , CAST(remedial_measure AS string)        AS remedial_measure
    , CAST(status AS string)                  AS status
    , CAST(note AS string)                    AS note
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(created_by AS string)              AS created_by
    , CAST(last_modified_by AS string)        AS last_modified_by
    , CAST(version AS bigint)                 AS version
    , CAST(deleted AS int)                    AS deleted
    , CAST(legal_document AS string)          AS legal_document
    , CAST(violation_clause AS string)        AS violation_clause
    , CAST(ecatalog_id AS string)             AS ecatalog_id
FROM {{ source('source_thanhtra', 'raw_violation_behavior') }}