/*
*--------------------------------------------------------------------*
* Program code: atm_pc_report_extension
* Program name: Atomic Pc Report Extension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , company_profile_id
        , form_cd
        , report_period
        , extension_days
        , doc_no
        , doc_date
        , report_year
        , report_quarter
    FROM {{ ref('ods_ids_report_extensions') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_REPORT_EXTENSIONS', "id") }}                  AS pc_rpt_extension_id
    , CAST(id AS string)                                                                AS pc_rpt_extension_code
    , CAST('IDS_REPORT_EXTENSIONS' AS string)                                           AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , {{ generate_surrogate_key_bigint('IDS_FORMS', "form_cd") }}                       AS fr_template_id
    , CAST(form_cd AS string)                                                           AS fr_template_code
    , CAST(report_period AS string)                                                     AS rpt_period_nm
    , CAST(extension_days AS int)                                                       AS extension_day_count
    , CAST(doc_no AS string)                                                            AS official_letter_nbr
    , CAST(doc_date AS date)                                                            AS official_letter_dt
    , CAST(report_year AS int)                                                          AS rpt_year
    , CAST(report_quarter AS int)                                                       AS rpt_quarter
FROM src
