/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_permissions
* Program name: Staging NHNCK.PERMISSIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(code AS string)            AS code
    , CAST(permission_name AS string) AS permission_name
    , CAST(parent_code AS string)     AS parent_code
    , CAST(abbreviation AS string)    AS abbreviation
    , CAST(sort_order AS bigint)      AS sort_order
    , CAST(is_active AS int)          AS is_active
    , CAST(is_menu AS int)            AS is_menu
    , CAST(path AS string)            AS path
    , CAST(description AS string)     AS description
FROM {{ source('source_nhnck', 'raw_permissions') }}