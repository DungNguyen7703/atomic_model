/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_departments
* Program name: Staging NHNCK.CERTIFICATE_DEPARTMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)               AS id
    , CAST(certificate_id AS bigint) AS certificate_id
    , CAST(department_id AS bigint)  AS department_id
FROM {{ source('source_nhnck', 'raw_certificate_departments') }}