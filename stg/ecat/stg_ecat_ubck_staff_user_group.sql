/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_ubck_staff_user_group
* Program name: Staging ECAT.UBCK_STAFF_USER_GROUP
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(ubck_staff_id AS string)   AS ubck_staff_id
    , CAST(user_group_id AS string)   AS user_group_id
    , CAST(user_group_code AS string) AS user_group_code
    , CAST(user_group_name AS string) AS user_group_name
FROM {{ source('source_ecat', 'raw_ubck_staff_user_group') }}