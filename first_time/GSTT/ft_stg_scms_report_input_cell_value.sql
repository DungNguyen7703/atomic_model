-- [FIRST-TIME] ft_stg_scms_report_input_cell_value: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily stg_scms_report_input_cell_value (config ft_target='report_input_cell_value', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: stg_scms_report_input_cell_value
* Program name: Staging SCMS.REPORT_INPUT_CELL_VALUE (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-23		tuan.nguyenvanb		Tao moi ban first-time tu stg daily (UAT). Bang nguon ~64 trieu dong:
*									- doc Oracle SONG SONG: chia 128 dai ID bang UNION ALL, moi nhanh co WHERE id tren
*									  cot goc de Spark day xuong Oracle (1 nhanh = 1 task JDBC rieng). Lo/hi lay lai moi lan
*									  chay bang MIN/MAX(id); dai dau mo duoi, dai cuoi mo tren.
*									- data_dt MOI DONG = ngay cua submission (COALESCE(last_modified_at, created_at)) thay
*									  vi bien ngay chay, de INSERT OVERWRITE dong chia dung tung partition data_dt nhu daily.
*--------------------------------------------------------------------*
*/

{#- Khi chua execute (dbt parse/compile khong ket noi DB) chi dung 0/1 de render duoc cau truc. -#}
{%- set num_parts = 128 -%}
{%- set id_lo     = 0 -%}
{%- set id_hi     = 1 -%}
{%- if execute -%}
    {%- set bounds = run_query('SELECT MIN(id) AS id_lo, MAX(id) AS id_hi FROM ' ~ source('source_scms', 'raw_report_input_cell_value')) -%}
    {%- if not bounds or bounds.rows | length == 0 or bounds.rows[0][0] is none or bounds.rows[0][1] is none -%}
        {{ exceptions.raise_compiler_error('ft_stg_scms_report_input_cell_value: khong lay duoc MIN/MAX(id) tu nguon (bang rong hoac truy van loi)') }}
    {%- endif -%}
    {%- set id_lo = bounds.rows[0][0] | int -%}
    {%- set id_hi = bounds.rows[0][1] | int -%}
{%- endif -%}
{%- set step      = ((id_hi - id_lo) / num_parts) | round(0, 'ceil') | int -%}

SELECT
    CAST(c.id AS decimal(19,0))                           AS id
    , CAST(c.report_input_submission_id AS decimal(19,0)) AS report_input_submission_id
    , CAST(c.sheet_id AS string)                          AS sheet_id
    , CAST(c.section_id AS string)                        AS section_id
    , CAST(c.cell_id AS string)                           AS cell_id
    , CAST(c.row_no AS bigint)                            AS row_no
    , CAST(c.item_value AS string)                        AS item_value
    , CAST(c.period_year AS int)                          AS period_year
    , CAST(c.ref_type AS string)                          AS ref_type
    -- [BACKFILL-UAT-ORIG] daily gan data_dt = ngay chay (bien ngay), first-time khong dung bien nay
    , to_date(COALESCE(s.last_modified_at, s.created_at)) AS data_dt   -- [BACKFILL-UAT-NEW] = ngay submission duoc tao/sua (giong gia tri daily se gan khi chay dung ngay do)
FROM (
{%- for i in range(num_parts) %}
    {%- set b_lo = id_lo + i * step %}
    {%- set b_hi = id_lo + (i + 1) * step %}
    {% if i > 0 %}UNION ALL{% endif %}
    SELECT id, report_input_submission_id, sheet_id, section_id, cell_id, row_no, item_value, period_year, ref_type
    FROM {{ source('source_scms', 'raw_report_input_cell_value') }}
    WHERE
    {%- if i == 0 %} id < {{ b_hi }}
    {%- elif i == num_parts - 1 %} id >= {{ b_lo }}
    {%- else %} id >= {{ b_lo }} AND id < {{ b_hi }}
    {%- endif %}
{%- endfor %}
) c
-- [BACKFILL-UAT-NEW] JOIN (thay cho IN submission theo ngay cua daily): lay ngay cua submission cho tung cell; INNER JOIN = loai cell mo coi nhu daily
JOIN (
    SELECT id, created_at, last_modified_at
    FROM {{ source('source_scms', 'raw_report_input_submission') }}
) s
    ON c.report_input_submission_id = s.id
-- [BACKFILL-UAT-ORIG] daily loc submission co created_at hoac last_modified_at roi vao ngay chay (bien ngay)
WHERE COALESCE(s.last_modified_at, s.created_at) IS NOT NULL   -- [BACKFILL-UAT-NEW] daily chi lay submission co ngay tao/sua; khong gioi han ngay -> nap FULL lich su
