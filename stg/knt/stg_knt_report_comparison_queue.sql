/*
*--------------------------------------------------------------------*
* Program code: stg_knt_report_comparison_queue
* Program name: Staging KNT.REPORT_COMPARISON_QUEUE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(action_type AS string)       AS action_type
    , CAST(ssc_report_detail_id AS int) AS ssc_report_detail_id
    , CAST(ssc_report_id AS int)        AS ssc_report_id
    , CAST(status AS string)            AS status
    , CAST(retry_count AS int)          AS retry_count
    , CAST(worker_id AS string)         AS worker_id
    , CAST(available_at AS timestamp)   AS available_at
    , CAST(started_at AS timestamp)     AS started_at
    , CAST(finished_at AS timestamp)    AS finished_at
    , CAST(error_message AS string)     AS error_message
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(source_system AS string)     AS source_system
    , CAST(detail_id AS int)            AS detail_id
    , CAST(header_id AS int)            AS header_id
    , CAST(legacy_created_at AS date)   AS legacy_created_at
FROM {{ source('source_knt', 'raw_report_comparison_queue') }}