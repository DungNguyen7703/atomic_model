/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_districts
* Program name: Staging NHNCK.DISTRICTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (7 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)              AS id
    , CAST(country_id AS bigint)    AS country_id
    , CAST(province_id AS bigint)   AS province_id
    , CAST(district_code AS string) AS district_code
    , CAST(district_name AS string) AS district_name
    , CAST(created_at AS timestamp) AS created_at
    , CAST(created_by AS bigint)    AS created_by
    , CAST(updated_at AS timestamp) AS updated_at
    , CAST(status AS bigint)        AS status
    , CAST(type AS bigint)          AS type
    , CAST(updated_by AS bigint)    AS updated_by
    , CAST(ecatalog_id AS string)   AS ecatalog_id
FROM {{ source('source_nhnck', 'raw_districts') }}