/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_penalty_type
* Program name: Staging THANHTRA.PENALTY_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot); them cot ecatalog_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(code AS string)             AS code
    , CAST(name AS string)             AS name
    , CAST(category AS string)         AS category
    , CAST(description AS string)      AS description
    , CAST(status AS string)           AS status
    , CAST(note AS string)             AS note
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(version AS bigint)          AS version
    , CAST(deleted AS int)             AS deleted
    , CAST(legal_basis AS string)      AS legal_basis
    , CAST(ecatalog_id AS string)      AS ecatalog_id
FROM {{ source('source_thanhtra', 'raw_penalty_type') }}