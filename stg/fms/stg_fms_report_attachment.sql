/*
*--------------------------------------------------------------------*
* Program code: stg_fms_report_attachment
* Program name: Staging FMS.REPORT_ATTACHMENT
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
    , CAST(datecreated AS date)          AS datecreated
    , CAST(reportname AS string)         AS reportname
    , CAST(reportcode AS string)         AS reportcode
    , CAST(periodtype AS decimal(38,0))  AS periodtype
    , CAST(periodvalue AS string)        AS periodvalue
    , CAST(report_year AS decimal(38,0)) AS report_year
    , CAST(filename AS string)           AS filename
FROM {{ source('source_fms', 'raw_report_attachment') }}
WHERE date_format(datecreated, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')