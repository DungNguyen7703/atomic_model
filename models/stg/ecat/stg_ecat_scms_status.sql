/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_scms_status
* Program name: Staging ECAT.SCMS_STATUS
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                     AS id
    , CAST(id_sync AS bigint)                AS id_sync
    , CAST(status_code AS string)            AS status_code
    , CAST(status_name AS string)            AS status_name
    , CAST(note AS string)                   AS note
    , CAST(created_by AS bigint)             AS created_by
    , CAST(report_submission_enabled AS int) AS report_submission_enabled
    , CAST(disclosure_enabled AS int)        AS disclosure_enabled
    , CAST(record_status AS int)             AS record_status
    , CAST(active AS int)                    AS active
    , CAST(code AS string)                   AS code
    , CAST(item_name AS string)              AS item_name
    , CAST(applicable_entity AS string)      AS applicable_entity
    , CAST(description AS string)            AS description
    , CAST(created_date AS timestamp)        AS created_date
    , CAST(last_updated_date AS timestamp)   AS last_updated_date
FROM {{ source('source_ecat', 'raw_scms_status') }}