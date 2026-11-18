/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_anti_money_laundering_document
* Program name: Staging THANHTRA.ANTI_MONEY_LAUNDERING_DOCUMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot); them cot dossier_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(document_type AS string)    AS document_type
    , CAST(document_number AS string)  AS document_number
    , CAST(issued_date AS date)        AS issued_date
    , CAST(summary AS string)          AS summary
    , CAST(document_year AS int)       AS document_year
    , CAST(quarter AS string)          AS quarter
    , CAST(receiving_unit AS string)   AS receiving_unit
    , CAST(note AS string)             AS note
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(version AS bigint)          AS version
    , CAST(deleted AS int)             AS deleted
    , CAST(dossier_id AS string)       AS dossier_id
FROM {{ source('source_thanhtra', 'raw_anti_money_laundering_document') }}