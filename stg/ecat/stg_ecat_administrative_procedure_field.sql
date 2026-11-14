/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_administrative_procedure_field
* Program name: Staging ECAT.ADMINISTRATIVE_PROCEDURE_FIELD
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                   AS id
    , CAST(id_sync AS string)              AS id_sync
    , CAST(code AS string)                 AS code
    , CAST(name AS string)                 AS name
    , CAST(description AS string)          AS description
    , CAST(effective AS int)               AS effective
    , CAST(source_created_at AS timestamp) AS source_created_at
    , CAST(source_updated_at AS timestamp) AS source_updated_at
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(updated_at AS timestamp)        AS updated_at
FROM {{ source('source_ecat', 'raw_administrative_procedure_field') }}