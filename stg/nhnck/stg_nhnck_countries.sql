/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_countries
* Program name: Staging NHNCK.COUNTRIES
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
    , CAST(country_code AS string)  AS country_code
    , CAST(country_name AS string)  AS country_name
    , CAST(is_default AS int)       AS is_default
    , CAST(created_at AS timestamp) AS created_at
    , CAST(created_by AS bigint)    AS created_by
    , CAST(updated_at AS timestamp) AS updated_at
    , CAST(status AS bigint)        AS status
    , CAST(updated_by AS bigint)    AS updated_by
    , CAST(ecatalog_id AS string)   AS ecatalog_id
FROM {{ source('source_nhnck', 'raw_countries') }}