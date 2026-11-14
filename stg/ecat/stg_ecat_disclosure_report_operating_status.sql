/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_disclosure_report_operating_status
* Program name: Staging ECAT.DISCLOSURE_REPORT_OPERATING_STATUS
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                          AS id
    , CAST(disclosure_report_id AS string)        AS disclosure_report_id
    , CAST(disclosure_report_stable_id AS string) AS disclosure_report_stable_id
    , CAST(status_id AS string)                   AS status_id
    , CAST(status_name AS string)                 AS status_name
    , CAST(id_sync AS string)                     AS id_sync
    , CAST(is_sync AS int)                        AS is_sync
    , CAST(deleted AS int)                        AS deleted
    , CAST(deleted_reason AS string)              AS deleted_reason
    , CAST(version AS int)                        AS version
    , CAST(effective_start_date AS timestamp)     AS effective_start_date
    , CAST(effective_end_date AS timestamp)       AS effective_end_date
    , CAST(old_id AS string)                      AS old_id
    , CAST(stable_id AS string)                   AS stable_id
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(updated_at AS timestamp)               AS updated_at
    , CAST(created_by_id AS string)               AS created_by_id
    , CAST(created_by_name AS string)             AS created_by_name
    , CAST(updated_by_id AS string)               AS updated_by_id
    , CAST(updated_by_name AS string)             AS updated_by_name
FROM {{ source('source_ecat', 'raw_disclosure_report_operating_status') }}