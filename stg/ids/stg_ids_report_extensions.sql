/*
*--------------------------------------------------------------------*
* Program code: stg_ids_report_extensions
* Program name: Staging IDS.REPORT_EXTENSIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(company_profile_id AS int) AS company_profile_id
    , CAST(form_cd AS string)         AS form_cd
    , CAST(report_period AS string)   AS report_period
    , CAST(extension_days AS int)     AS extension_days
    , CAST(doc_no AS string)          AS doc_no
    , CAST(doc_date AS date)          AS doc_date
    , CAST(report_year AS int)        AS report_year
    , CAST(report_quarter AS int)     AS report_quarter
    , CAST(created_by AS string)      AS created_by
    , CAST(created_date AS date)      AS created_date
    , CAST(updated_by AS string)      AS updated_by
    , CAST(updated_date AS date)      AS updated_date
FROM {{ source('source_ids', 'raw_report_extensions') }}