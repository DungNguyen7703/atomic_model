/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_statuses
* Program name: Staging NHNCK.APPLICATION_STATUSES
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
    , CAST(status_code AS string)   AS status_code
    , CAST(status_name AS string)   AS status_name
    , CAST(label AS string)         AS label
    , CAST(description AS string)   AS description
    , CAST(sort_order AS bigint)    AS sort_order
    , CAST(is_active AS int)        AS is_active
    , CAST(is_original_data AS int) AS is_original_data
    , CAST(created_by AS bigint)    AS created_by
    , CAST(updated_by AS bigint)    AS updated_by
    , CAST(created_at AS timestamp) AS created_at
    , CAST(updated_at AS timestamp) AS updated_at
FROM {{ source('source_nhnck', 'raw_application_statuses') }}