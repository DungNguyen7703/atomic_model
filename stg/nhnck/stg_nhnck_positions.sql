/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_positions
* Program name: Staging NHNCK.POSITIONS
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
    , CAST(position_name AS string) AS position_name
    , CAST(description AS string)   AS description
    , CAST(created_at AS timestamp) AS created_at
    , CAST(created_by AS bigint)    AS created_by
    , CAST(updated_at AS timestamp) AS updated_at
    , CAST(is_active AS int)        AS is_active
    , CAST(status AS bigint)        AS status
    , CAST(updated_by AS bigint)    AS updated_by
    , CAST(ecatalog_id AS string)   AS ecatalog_id
    , CAST(position_code AS string) AS position_code
FROM {{ source('source_nhnck', 'raw_positions') }}