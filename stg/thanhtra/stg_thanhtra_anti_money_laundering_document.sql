/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_anti_money_laundering_document
* Program name: Staging THANHTRA.ANTI_MONEY_LAUNDERING_DOCUMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(document_type AS string)    AS document_type
    , CAST(document_number AS string)  AS document_number
    , CAST(issued_date AS date)        AS issued_date
    , CAST(summary AS string)          AS summary
    , CAST(document_year AS int)       AS document_year
    , CAST(quarter AS string)          AS quarter
    , CAST(receiving_unit AS string)   AS receiving_unit
    , CAST(note AS string)             AS note
    , CAST(created_at AS date)         AS created_at
    , CAST(last_modified_at AS date)   AS last_modified_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(version AS bigint)          AS version
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_thanhtra', 'raw_anti_money_laundering_document') }}