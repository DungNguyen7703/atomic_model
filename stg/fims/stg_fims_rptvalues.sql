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
    , CAST(datecreated AS date)        AS datecreated
    , CAST(createdby AS string)        AS createdby
    , CAST(datemodified AS date)       AS datemodified
    , CAST(modifyby AS string)         AS modifyby
    , CAST(mebid AS decimal(18,2))     AS mebid
    , CAST(prdid AS decimal(18,2))     AS prdid
    , CAST(sheetid AS decimal(18,2))   AS sheetid
    , CAST(rptid AS decimal(18,2))     AS rptid
    , CAST(tgtid AS string)            AS tgtid
    , CAST(type AS int)                AS type
    , CAST(periodtype AS int)          AS periodtype
    , CAST(periodvalue AS string)      AS periodvalue
    , CAST(yearvalue AS decimal(18,2)) AS yearvalue
    , CAST(values AS string)           AS values
    , CAST(code AS string)             AS code
    , CAST(formatdatatype AS string)   AS formatdatatype
    , CAST(isdynamic AS int)       AS isdynamic
    , CAST(rowdynamic AS int)          AS rowdynamic
    , CAST(tablename AS string)        AS tablename
    , CAST(fieldname AS string)        AS fieldname
    , CAST(identification AS int)      AS identification
    , CAST(fundid AS decimal(18,2))    AS fundid
    , CAST(secid AS decimal(18,2))     AS secid
    , CAST(bankid AS decimal(18,2))    AS bankid
    , CAST(depid AS decimal(18,2))     AS depid
    , CAST(stockid AS decimal(18,2))   AS stockid
    , CAST(inid AS decimal(18,2))      AS inid
    , CAST(branid AS decimal(18,2))    AS branid
FROM raw_union