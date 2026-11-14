/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_administrative_procedure_component_mapping
* Program name: Staging ECAT.ADMINISTRATIVE_PROCEDURE_COMPONENT_MAPPING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: them cot administrative_procedure_stable_id.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(administrative_procedure_id AS string) AS administrative_procedure_id
    , CAST(component_id AS string)              AS component_id
    , CAST(administrative_procedure_stable_id AS string) AS administrative_procedure_stable_id
    , CAST(component_stable_id AS string)       AS component_stable_id
FROM {{ source('source_ecat', 'raw_administrative_procedure_component_mapping') }}