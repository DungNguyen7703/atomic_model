/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_position_type_department
* Program name: Staging ECAT.POSITION_TYPE_DEPARTMENT
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(position_type_version_id AS string) AS position_type_version_id
    , CAST(position_type_stable_id AS string)  AS position_type_stable_id
    , CAST(department_version_id AS string)    AS department_version_id
    , CAST(department_stable_id AS string)     AS department_stable_id
FROM {{ source('source_ecat', 'raw_position_type_department') }}