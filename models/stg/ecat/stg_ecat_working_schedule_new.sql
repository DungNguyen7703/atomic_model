/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_working_schedule_new
* Program name: Staging ECAT.WORKING_SCHEDULE_NEW
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
    CAST(id AS string)                      AS id
    , CAST(description AS string)             AS description
    , CAST(date_applied AS date)              AS date_applied
    , CAST(type AS int)                       AS type
    , CAST(change_reason AS string)           AS change_reason
    , CAST(active AS int)                     AS active
    , CAST(deleted AS int)                    AS deleted
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(version AS int)                    AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(active_reason AS string)           AS active_reason
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(stable_id AS string)               AS stable_id
FROM {{ source('source_ecat', 'raw_working_schedule_new') }}