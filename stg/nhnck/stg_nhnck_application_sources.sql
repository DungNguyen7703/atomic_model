/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_sources
* Program name: Staging NHNCK.APPLICATION_SOURCES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (4 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(code AS string)          AS code
    , CAST(name AS string)          AS name
    , CAST(label AS string)         AS label
    , CAST(status AS bigint)        AS status
    , CAST(description AS string)   AS description
    , CAST(created_by AS bigint)    AS created_by
    , CAST(updated_by AS bigint)    AS updated_by
    , CAST(created_at AS timestamp) AS created_at
    , CAST(updated_at AS timestamp) AS updated_at
FROM {{ source('source_nhnck', 'raw_application_sources') }}