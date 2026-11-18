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
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: WHERE loc theo BRD filter_logic; yml snapshot/ds_snpst_dt -> append/created_at theo BRD.
* 2026-11-08		tuan.nguyenvanb		Dong bo kieu theo dictionary Oracle KNT (query ket qua 2026-11-08, quy tac map cua DDL prod; CHUA khao sat du lieu): kieu int sang decimal(38,10) (6 cot); kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(38,10))                   AS id
    , CAST(action_type AS string)                  AS action_type
    , CAST(ssc_report_detail_id AS decimal(38,10)) AS ssc_report_detail_id
    , CAST(ssc_report_id AS decimal(38,10))        AS ssc_report_id
    , CAST(status AS string)                       AS status
    , CAST(retry_count AS decimal(38,10))          AS retry_count
    , CAST(worker_id AS string)                    AS worker_id
    , CAST(available_at AS timestamp)              AS available_at
    , CAST(started_at AS timestamp)                AS started_at
    , CAST(finished_at AS timestamp)               AS finished_at
    , CAST(error_message AS string)                AS error_message
    , CAST(created_at AS timestamp)                AS created_at
    , CAST(source_system AS string)                AS source_system
    , CAST(detail_id AS decimal(38,10))            AS detail_id
    , CAST(header_id AS decimal(38,10))            AS header_id
    , CAST(legacy_created_at AS timestamp)         AS legacy_created_at
FROM {{ source('source_knt', 'raw_report_comparison_queue') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1