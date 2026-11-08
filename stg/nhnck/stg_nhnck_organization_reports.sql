/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_organization_reports
* Program name: Staging NHNCK.ORGANIZATION_REPORTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date                User                Description
*--------------------------------------------------------------------*
*/
{% if execute and flags.WHICH == 'run' %}
    {% do run_query('SET spark.sql.datetime.java8API.enabled=false') %}
{% endif %}

{% set etl_date = var('etl_date') %}
{% set next_date = (
    modules.datetime.datetime.strptime(etl_date, '%Y-%m-%d')
    + modules.datetime.timedelta(days=1)
).strftime('%Y-%m-%d') %}

SELECT
    CAST(id AS bigint)                      AS id
    , CAST(organization_id AS bigint)       AS organization_id
    , CAST(professional_id AS bigint)       AS professional_id
    , CAST(certificate_id AS bigint)        AS certificate_id
    , CAST(certificate_record_id AS bigint) AS certificate_record_id
    , CAST(full_name AS string)             AS full_name
    , CAST(birth_date AS date)              AS birth_date
    , CAST(identity_number AS string)       AS identity_number
    , CAST(position AS string)              AS position
    , CAST(department AS string)            AS department
    , CAST(workplace AS string)             AS workplace
    , CAST(hire_date AS date)               AS hire_date
    , CAST(termination_date AS date)        AS termination_date
    , CAST(certificate_number AS string)    AS certificate_number
    , CAST(issue_date AS date)              AS issue_date
    , CAST(disciplines AS string)           AS disciplines
    , CAST(description AS string)           AS description
    , CAST(report_date AS date)             AS report_date
    , CAST(sync_id AS string)               AS sync_id
    , CAST(sync_created_at AS timestamp)    AS sync_created_at
    , CAST(sync_updated_at AS timestamp)    AS sync_updated_at
    , CAST(type AS bigint)                  AS type
    , CAST(parent_report_id AS bigint)      AS parent_report_id
    , CAST(status AS bigint)                AS status
    , CAST(status_organization AS bigint)   AS status_organization
    , CAST(file_path AS string)             AS file_path
    , CAST(file_path_termination AS string) AS file_path_termination
    , CAST(business_department AS string)   AS business_department
    , CAST(notes AS string)                 AS notes
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(created_by AS bigint)            AS created_by
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(updated_by AS bigint)            AS updated_by
FROM {{ source('source_nhnck', 'raw_organization_reports') }}
WHERE created_at >= TIMESTAMP '{{ etl_date }} 00:00:00'
  AND created_at < TIMESTAMP '{{ next_date }} 00:00:00'
