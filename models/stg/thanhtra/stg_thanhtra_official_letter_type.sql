/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_official_letter_type
* Program name: Staging THANHTRA.OFFICIAL_LETTER_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(code AS string)                         AS code
    , CAST(label AS string)                        AS label
    , CAST(group_code AS string)                   AS group_code
    , CAST(preferred_source_entity_type AS string) AS preferred_source_entity_type
    , CAST(sort_order AS bigint)                   AS sort_order
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(created_by AS string)                   AS created_by
    , CAST(last_modified_at AS timestamp)          AS last_modified_at
    , CAST(last_modified_by AS string)             AS last_modified_by
    , CAST(version AS bigint)                      AS version
    , CAST(deleted AS int)                         AS deleted
FROM {{ source('source_thanhtra', 'raw_official_letter_type') }}