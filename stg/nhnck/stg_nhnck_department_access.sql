/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_department_access
* Program name: Staging NHNCK.DEPARTMENT_ACCESS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                     AS id
    , CAST(department_id AS bigint)        AS department_id
    , CAST(department_access_id AS bigint) AS department_access_id
FROM {{ source('source_nhnck', 'raw_department_access') }}