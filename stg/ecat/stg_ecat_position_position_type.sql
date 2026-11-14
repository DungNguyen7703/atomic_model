/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_position_position_type
* Program name: Staging ECAT.POSITION_POSITION_TYPE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(position_version_id AS string)      AS position_version_id
    , CAST(position_type_version_id AS string) AS position_type_version_id
    , CAST(position_stable_id AS string)       AS position_stable_id
    , CAST(position_type_stable_id AS string)  AS position_type_stable_id
FROM {{ source('source_ecat', 'raw_position_position_type') }}