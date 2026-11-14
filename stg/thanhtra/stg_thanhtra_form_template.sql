/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_form_template
* Program name: Staging THANHTRA.FORM_TEMPLATE
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
    , CAST(code AS string)             AS code
    , CAST(name AS string)             AS name
    , CAST(category AS string)         AS category
    , CAST(current_version AS bigint)  AS current_version
    , CAST(status AS string)           AS status
    , CAST(created_at AS timestamp)    AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(version AS bigint)          AS version
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_thanhtra', 'raw_form_template') }}