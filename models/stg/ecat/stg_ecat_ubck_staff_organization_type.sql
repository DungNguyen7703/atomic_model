/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_ubck_staff_organization_type
* Program name: Staging ECAT.UBCK_STAFF_ORGANIZATION_TYPE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(ubck_staff_id AS string)        AS ubck_staff_id
    , CAST(organization_type_id AS string) AS organization_type_id
FROM {{ source('source_ecat', 'raw_ubck_staff_organization_type') }}