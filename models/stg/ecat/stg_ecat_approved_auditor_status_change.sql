/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_approved_auditor_status_change
* Program name: Staging ECAT.APPROVED_AUDITOR_STATUS_CHANGE
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(id_sync AS bigint)                 AS id_sync
    , CAST(approved_auditor_id AS string)     AS approved_auditor_id
    , CAST(event_type_id AS string)           AS event_type_id
    , CAST(event_type_name AS string)         AS event_type_name
    , CAST(effective_date AS timestamp)       AS effective_date
    , CAST(reason AS string)                  AS reason
    , CAST(additional_description AS string)  AS additional_description
    , CAST(deleted AS int)                    AS deleted
    , CAST(deleted_reason AS string)          AS deleted_reason
    , CAST(version AS decimal(38,10))         AS version
    , CAST(effective_start_date AS timestamp) AS effective_start_date
    , CAST(effective_end_date AS timestamp)   AS effective_end_date
    , CAST(old_id AS string)                  AS old_id
    , CAST(stable_id AS string)               AS stable_id
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(updated_at AS timestamp)           AS updated_at
    , CAST(created_by_id AS string)           AS created_by_id
    , CAST(created_by_name AS string)         AS created_by_name
    , CAST(updated_by_id AS string)           AS updated_by_id
    , CAST(updated_by_name AS string)         AS updated_by_name
    , CAST(created_by AS string)              AS created_by
FROM {{ source('source_ecat', 'raw_approved_auditor_status_change') }}