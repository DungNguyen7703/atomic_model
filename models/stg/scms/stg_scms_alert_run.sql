/*
*--------------------------------------------------------------------*
* Program code: stg_scms_alert_run
* Program name: Staging SCMS.ALERT_RUN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang decimal(19,0) (2 cot); kieu int sang bigint (3 cot).
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (created_at) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(created_at,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                           AS id
    , CAST(run_id AS string)                              AS run_id
    , CAST(alert_target_entity AS string)                 AS alert_target_entity
    , CAST(data_year AS bigint)                           AS data_year
    , CAST(data_period AS string)                         AS data_period
    , CAST(alert_indicator_id AS decimal(19,0))           AS alert_indicator_id
    , CAST(performer_name AS string)                      AS performer_name
    , CAST(start_time AS timestamp)                       AS start_time
    , CAST(end_time AS timestamp)                         AS end_time
    , CAST(record_status AS string)                       AS record_status
    , CAST(alert_count_generated AS bigint)               AS alert_count_generated
    , CAST(error_message AS string)                       AS error_message
    , CAST(created_at AS timestamp)                       AS created_at
    , CAST(alert_indicator_condition_id AS decimal(19,0)) AS alert_indicator_condition_id
    , CAST(period_type AS int)                            AS period_type
    , CAST(period_value AS bigint)                        AS period_value
    , CAST(run_mode AS string)                            AS run_mode
FROM {{ source('source_scms', 'raw_alert_run') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1