/*
*--------------------------------------------------------------------*
* Program code: stg_ids_report_catalog
* Program name: Staging IDS.REPORT_CATALOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                          AS id
    , CAST(report_cd AS string)              AS report_cd
    , CAST(report_name_vi AS string)         AS report_name_vi
    , CAST(report_name_en AS string)         AS report_name_en
    , CAST(rc_type_cd AS string)             AS rc_type_cd
    , CAST(report_year AS string)            AS report_year
    , CAST(report_scope_cd AS string)        AS report_scope_cd
    , CAST(enterprise_type_cd AS string)     AS enterprise_type_cd
    , CAST(consolidated_flg AS int)          AS consolidated_flg
    , CAST(active_flg AS int)                AS active_flg
    , CAST(is_deleted AS int)                AS is_deleted
    , CAST(created_by AS string)             AS created_by
    , CAST(created_date AS date)             AS created_date
    , CAST(updated_by AS string)             AS updated_by
    , CAST(updated_date AS date)             AS updated_date
    , CAST(financial_statement_cd AS string) AS financial_statement_cd
    , CAST(reporting_period_cd AS string)    AS reporting_period_cd
    , CAST(ref_cd AS string)                 AS ref_cd
FROM {{ source('source_ids', 'raw_report_catalog') }}