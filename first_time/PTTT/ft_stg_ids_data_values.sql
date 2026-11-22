-- [FIRST-TIME] ft_stg_ids_data_values: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily stg_ids_data_values (config ft_target='data_values', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: stg_ids_data_values
* Program name: Staging IDS.DATA_VALUES (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-16		tuan.nguyenvanb		Tao moi: bo loc created/updated theo ngay de nap FULL lich su IDS.DATA_VALUES mot lan, data_dt = etl_date (cung layout stg daily).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                                AS id
    , CAST(field_name_vi AS string)                   AS field_name_vi
    , CAST(field_name_en AS string)                   AS field_name_en
    , CAST(text_value AS string)                      AS text_value
    , CAST(date_value AS date)                        AS date_value
    , CAST(number_value AS decimal(23,2))             AS number_value
    , CAST(company_data_id AS bigint)                 AS company_data_id
    , CAST(parent_id AS bigint)                       AS parent_id
    , CAST(form_id AS bigint)                         AS form_id
    , CAST(field_id AS bigint)                        AS field_id
    , CAST(form_field_id AS bigint)                   AS form_field_id
    , CAST(field_parent_id AS bigint)                 AS field_parent_id
    , CAST(data_type AS string)                       AS data_type
    , CAST(required_flg AS int)                       AS required_flg
    , CAST(created_by AS string)                      AS created_by
    , CAST(created_date AS timestamp)                 AS created_date
    , CAST(updated_by AS string)                      AS updated_by
    , CAST(updated_date AS timestamp)                 AS updated_date
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')  AS data_dt
FROM {{ source('source_ids', 'raw_data_values') }}
-- [BACKFILL-UAT-ORIG] daily loc created_date/updated_date theo ngay chay; first-time lay TOAN BO bang nguon, data_dt = etl_date (dong dau cua lich su)
