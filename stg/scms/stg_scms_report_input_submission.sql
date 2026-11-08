/*
*--------------------------------------------------------------------*
* Program code: stg_scms_report_input_submission
* Program name: Staging SCMS.REPORT_INPUT_SUBMISSION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                AS id
    , CAST(ref_type AS string)               AS ref_type
    , CAST(ref_id AS decimal(19,0))          AS ref_id
    , CAST(form_report_id AS decimal(19,0))  AS form_report_id
    , CAST(form_version_id AS decimal(19,0)) AS form_version_id
    , CAST(period_year AS int)               AS period_year
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') as data_dt
FROM {{ source('source_scms', 'raw_report_input_submission') }}
where date_format(created_at, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
or date_format(last_modified_at, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')