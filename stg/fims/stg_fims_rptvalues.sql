/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rptvalues
* Program name: Staging FIMS.RPTVALUES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

{% set year_list = var('rptvalues_years', range(2020, 2027) | list) %}
{% set year_list = year_list | map('string') | list %}

{% set like_clauses = [] %}
{% for y in year_list %}
  {% do like_clauses.append('RPTVALUES*' ~ y) %}
{% endfor %}
{% set like_pattern = like_clauses | join('|') %}
{% set show_tables_sql %}
    SHOW TABLES IN {{ var('src_fims_schema') }} LIKE '{{ like_pattern }}'
{% endset %}

{% set re = modules.re %}
{% set year_alt = year_list | join('|') %}
{% set month_year_pattern = re.compile('^RPTVALUES[0-9]{1,2}(' ~ year_alt ~ ')$', re.IGNORECASE) %}

{% set monthly_tables = [] %}
{% if execute %}
  {% set results = run_query(show_tables_sql) %}
  {% for row in results %}
    {% if month_year_pattern.match(row[1]) %}
      {% do monthly_tables.append(row[1]) %}
    {% endif %}
  {% endfor %}
{% endif %}

{% set raw_columns %}
        id, deleted, datecreated, createdby, datemodified, modifyby, mebid, prdid,
        sheetid, rptid, tgtid, type, periodtype, periodvalue, yearvalue, values,
        code, formatdatatype, isdynamic, rowdynamic, tablename, fieldname,
        identification, fundid, secid, bankid, depid, stockid, inid, branid
{% endset %}

WITH raw_union AS (
{% if monthly_tables | length > 0 %}
  {% for tbl in monthly_tables %}
    SELECT {{ raw_columns }}
    FROM {{ var('src_fims_schema') }}.{{ tbl }}
    {{ "UNION ALL" if not loop.last }}
  {% endfor %}
{% else %}
    SELECT {{ raw_columns }}
    FROM {{ source('source_fims', 'raw_rptvalues') }}
{% endif %}
)

SELECT
    CAST(id AS string)                 AS id
    , CAST(deleted AS int)         AS deleted
    , CAST(datecreated AS timestamp)        AS datecreated
    , CAST(createdby AS string)        AS createdby
    , CAST(datemodified AS timestamp)       AS datemodified
    , CAST(modifyby AS string)         AS modifyby
    , CAST(mebid AS bigint)     AS mebid
    , CAST(prdid AS bigint)     AS prdid
    , CAST(sheetid AS bigint)   AS sheetid
    , CAST(rptid AS bigint)     AS rptid
    , CAST(tgtid AS string)            AS tgtid
    , CAST(type AS int)                AS type
    , CAST(periodtype AS bigint)          AS periodtype
    , CAST(periodvalue AS string)      AS periodvalue
    , CAST(yearvalue AS int) AS yearvalue
    , CAST(values AS string)           AS values
    , CAST(code AS string)             AS code
    , CAST(formatdatatype AS string)   AS formatdatatype
    , CAST(isdynamic AS int)       AS isdynamic
    , CAST(rowdynamic AS bigint)          AS rowdynamic
    , CAST(tablename AS string)        AS tablename
    , CAST(fieldname AS string)        AS fieldname
    , CAST(identification AS int)      AS identification
    , CAST(fundid AS bigint)    AS fundid
    , CAST(secid AS bigint)     AS secid
    , CAST(bankid AS bigint)    AS bankid
    , CAST(depid AS bigint)     AS depid
    , CAST(stockid AS bigint)   AS stockid
    , CAST(inid AS bigint)      AS inid
    , CAST(branid AS bigint)    AS branid
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AS data_dt
FROM raw_union
-- WHERE (datecreated >= TO_TIMESTAMP('{{ var("etl_date") }}')
--   AND datecreated <  TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY)
--    OR (datemodified >= TO_TIMESTAMP('{{ var("etl_date") }}')
--   AND datemodified <  TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY)