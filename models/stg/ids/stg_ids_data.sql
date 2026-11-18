/*
*--------------------------------------------------------------------*
* Program code: stg_ids_data
* Program name: Staging IDS.DATA
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-15		Claude				Doc Oracle SONG SONG: chia 128 dai ID bang UNION ALL, moi nhanh
*									co WHERE id tren cot goc de Spark day xuong Oracle (1 nhanh = 1
*									task JDBC rieng). Lo/hi LUON lay lai moi lan chay bang MIN/MAX(id),
*									khong co gia tri mac dinh. Dai dau mo duoi, dai cuoi mo tren nen
*									dong moi vuot MAX(ID) luc do van duoc doc du. So ket noi Oracle
*									dong thoi toi da bang so core Spark kha dung.
*--------------------------------------------------------------------*
*/

{#- Neu truy van MIN/MAX loi hoac bang rong thi model bao loi (khong am tham doc sai dai ID).
    Khi chua execute (dbt parse/compile khong ket noi DB) chi dung 0/1 de render duoc cau truc. -#}
{%- set num_parts = 128 -%}
{%- set id_lo     = 0 -%}
{%- set id_hi     = 1 -%}
{%- if execute -%}
    {%- set bounds = run_query('SELECT MIN(id) AS id_lo, MAX(id) AS id_hi FROM ' ~ source('source_ids', 'raw_data')) -%}
    {%- if not bounds or bounds.rows | length == 0 or bounds.rows[0][0] is none or bounds.rows[0][1] is none -%}
        {{ exceptions.raise_compiler_error('stg_ids_data: khong lay duoc MIN/MAX(id) tu nguon (bang rong hoac truy van loi)') }}
    {%- endif -%}
    {%- set id_lo = bounds.rows[0][0] | int -%}
    {%- set id_hi = bounds.rows[0][1] | int -%}
{%- endif -%}
{%- set step      = ((id_hi - id_lo) / num_parts) | round(0, 'ceil') | int -%}

SELECT
    CAST(id AS bigint)                   AS id
    , CAST(report_catalog_id AS bigint)  AS report_catalog_id
    , CAST(data_value AS decimal(38,8))  AS data_value
    , CAST(report_year AS int)           AS report_year
    , CAST(report_quarter AS int)        AS report_quarter
    , CAST(cell_enabled_flg AS int)      AS cell_enabled_flg
    , CAST(rc_type AS string)            AS rc_type
    , CAST(row_cd AS string)             AS row_cd
    , CAST(col_cd AS string)             AS col_cd
    , CAST(created_by AS string)         AS created_by
    , CAST(created_date AS date)         AS created_date
    , CAST(updated_by AS string)         AS updated_by
    , CAST(updated_date AS date)         AS updated_date
    , CAST(company_profile_id AS int)    AS company_profile_id
FROM (
{%- for i in range(num_parts) %}
    {%- set b_lo = id_lo + i * step %}
    {%- set b_hi = id_lo + (i + 1) * step %}
    {% if i > 0 %}UNION ALL{% endif %}
    SELECT id, report_catalog_id, data_value, report_year, report_quarter, cell_enabled_flg, rc_type, row_cd, col_cd, created_by, created_date, updated_by, updated_date, company_profile_id
    FROM {{ source('source_ids', 'raw_data') }}
    WHERE
    {%- if i == 0 %} id < {{ b_hi }}
    {%- elif i == num_parts - 1 %} id >= {{ b_lo }}
    {%- else %} id >= {{ b_lo }} AND id < {{ b_hi }}
    {%- endif %}
{%- endfor %}
) _raw
