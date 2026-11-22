-- [FIRST-TIME] ft_stg_mrms_risk_indicator_value: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily stg_mrms_risk_indicator_value (config ft_target='risk_indicator_value', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: stg_mrms_risk_indicator_value
* Program name: Staging MRMS.RISK_INDICATOR_VALUE (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-16		tuan.nguyenvanb		Tao moi: bo loc created/updated theo ngay de nap FULL lich su, data_dt = etl_date; strategy snapshot (ds_snpst_dt = etl_date) nhu daily.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(indicator_id AS string)             AS indicator_id
    , CAST(period_type AS int)                 AS period_type
    , CAST(period_value AS int)                AS period_value
    , CAST(period_year AS int)                 AS period_year
    , CAST(period_date AS timestamp)           AS period_date
    , CAST(period_label AS string)             AS period_label
    , CAST(unit_code AS int)                   AS unit_code
    , CAST(source_code AS int)                 AS source_code
    , CAST(data_origin AS int)                 AS data_origin
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(created_by_id AS string)            AS created_by_id
    , CAST(updated_by_id AS string)            AS updated_by_id
    , CAST(created_by_name AS string)          AS created_by_name
    , CAST(updated_by_name AS string)          AS updated_by_name
    , CAST(deleted AS int)                     AS deleted
    , CAST(cumulative_value AS decimal(19,4))  AS cumulative_value
    , CAST(value AS decimal(19,4))             AS value
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')  AS data_dt
FROM {{ source('source_mrms', 'raw_risk_indicator_value') }}
-- [BACKFILL-UAT-ORIG] daily loc created_at/updated_at theo ngay chay; first-time lay TOAN BO bang nguon, data_dt = etl_date; macro snapshot them ds_snpst_dt = etl_date
