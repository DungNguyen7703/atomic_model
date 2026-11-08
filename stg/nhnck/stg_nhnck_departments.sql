/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_departments
* Program name: Staging NHNCK.DEPARTMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (4 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(unit_id AS bigint)         AS unit_id
    , CAST(department_code AS string) AS department_code
    , CAST(department_name AS string) AS department_name
    , CAST(sort_order AS bigint)      AS sort_order
    , CAST(description AS string)     AS description
    , CAST(status AS bigint)          AS status
    , CAST(ecatalog_id AS string)     AS ecatalog_id
FROM {{ source('source_nhnck', 'raw_departments') }}