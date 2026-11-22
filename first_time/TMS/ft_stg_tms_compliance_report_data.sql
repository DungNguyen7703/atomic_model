-- [FIRST-TIME] ft_stg_tms_compliance_report_data: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily stg_tms_compliance_report_data (config ft_target='compliance_report_data', macro macros/first_time).
-- 2026-11-19 tuan.nguyenvanb: [FIRST-TIME TMS] Lay FULL bang nguon (bo loc created_at/updated_at theo ngay chay); data_dt = ngay thay doi cuoi
-- cua dong = COALESCE(updated_at, created_at) (khong co ngay -> etl_date) de moi dong nam dung partition ma daily se ghi.


SELECT
    CAST(id AS string)                AS id
    , CAST(report_form_id AS string)    AS report_form_id
    , CAST(row_index AS bigint)         AS row_index
    , CAST(row_data AS string)          AS row_data
    , CAST(validation_status AS int)    AS validation_status
    , CAST(validation_errors AS string) AS validation_errors
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by_id AS string)     AS created_by_id
    , CAST(updated_by_id AS string)     AS updated_by_id
    , CAST(created_by_name AS string)   AS created_by_name
    , CAST(updated_by_name AS string)   AS updated_by_name
    , CAST(deleted AS int)              AS deleted
    , COALESCE(to_date(COALESCE(updated_at, created_at)), to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')) AS data_dt
FROM {{ source('source_tms', 'raw_compliance_report_data') }}
-- [BACKFILL-ORIG] WHERE (created_at >= TO_TIMESTAMP('{{ var("etl_date") }}') AND created_at < TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY) OR (updated_at >= TO_TIMESTAMP('{{ var("etl_date") }}') AND updated_at < TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY)
