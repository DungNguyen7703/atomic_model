/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_private_catalog_item
* Program name: Staging THANHTRA.PRIVATE_CATALOG_ITEM
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(catalog_type AS string)     AS catalog_type
    , CAST(code AS string)             AS code
    , CAST(name AS string)             AS name
    , CAST(item_value AS string)       AS item_value
    , CAST(status AS string)           AS status
    , CAST(sort_order AS bigint)       AS sort_order
    , CAST(note AS string)             AS note
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(version AS bigint)          AS version
    , CAST(deleted AS int)             AS deleted
    , CAST(description AS string)      AS description
FROM {{ source('source_thanhtra', 'raw_private_catalog_item') }}