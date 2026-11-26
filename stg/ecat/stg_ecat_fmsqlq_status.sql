/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_fmsqlq_status
* Program name: Staging ECAT.FMSQLQ_STATUS
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-10		tuan.nguyenvanb		Dong bo theo DDL final (drive-download 2026-11-10): kieu du lieu 1 cot theo DDL final.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(created_by AS string)       AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)        AS modify_by
    , CAST(item_name AS string)        AS item_name
    , CAST(type_sec AS int)  AS type_sec
    , CAST(active AS int)              AS active
    , CAST(submit_report AS int)       AS submit_report
    , CAST(description AS string)      AS description
    , CAST(deleted AS int)             AS deleted
    , CAST(id_sync AS string)          AS id_sync
FROM {{ source('source_ecat', 'raw_fmsqlq_status') }}