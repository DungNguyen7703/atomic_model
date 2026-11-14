/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_anti_money_laundering_report
* Program name: Staging THANHTRA.ANTI_MONEY_LAUNDERING_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production THANHTRA_ddl_prod.sql: kieu date sang timestamp (2 cot); them cot report_date.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(name AS string)                    AS name
    , CAST(report_type AS string)             AS report_type
    , CAST(report_year AS int)                AS report_year
    , CAST(period_type AS string)             AS period_type
    , CAST(requesting_authority AS string)    AS requesting_authority
    , CAST(request_document_number AS string) AS request_document_number
    , CAST(content AS string)                 AS content
    , CAST(note AS string)                    AS note
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(created_by AS string)              AS created_by
    , CAST(last_modified_by AS string)        AS last_modified_by
    , CAST(version AS bigint)                 AS version
    , CAST(deleted AS int)                    AS deleted
    , CAST(report_date AS date)               AS report_date
FROM {{ source('source_thanhtra', 'raw_anti_money_laundering_report') }}