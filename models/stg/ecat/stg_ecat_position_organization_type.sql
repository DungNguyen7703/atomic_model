/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_position_organization_type
* Program name: Staging ECAT.POSITION_ORGANIZATION_TYPE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(position_id AS string)          AS position_id
    , CAST(organization_type_id AS string) AS organization_type_id
    , CAST(position_stable_id AS string)   AS position_stable_id
FROM {{ source('source_ecat', 'raw_position_organization_type') }}