/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_education_levels
* Program name: Staging NHNCK.EDUCATION_LEVELS
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
    , CAST(level_name AS string)    AS level_name
    , CAST(description AS string)   AS description
    , CAST(is_displayed AS int)     AS is_displayed
    , CAST(is_original_data AS int) AS is_original_data
    , CAST(status AS bigint)        AS status
    , CAST(updated_at AS timestamp) AS updated_at
    , CAST(created_at AS timestamp) AS created_at
    , CAST(created_by AS bigint)    AS created_by
    , CAST(updated_by AS bigint)    AS updated_by
FROM {{ source('source_nhnck', 'raw_education_levels') }}