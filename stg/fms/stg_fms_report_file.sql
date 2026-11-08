/*
*--------------------------------------------------------------------*
* Program code: stg_fms_report_file
* Program name: Staging FMS.REPORT_FILE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , CAST(report_name AS string)        AS report_name
    , CAST(report_code AS string)        AS report_code
    , CAST(period_type AS decimal(18,2)) AS period_type
    , CAST(period_value AS string)       AS period_value
    , CAST(report_year AS decimal(18,2)) AS report_year
    , CAST(file_name AS string)          AS file_name
    , CAST(description AS string)        AS description
    , CAST(date_created AS date)         AS date_created
FROM {{ source('source_fms', 'raw_report_file') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')