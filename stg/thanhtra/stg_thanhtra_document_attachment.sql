/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_document_attachment
* Program name: Staging THANHTRA.DOCUMENT_ATTACHMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                  AS id
    , CAST(entity_type AS string)       AS entity_type
    , CAST(entity_id AS string)         AS entity_id
    , CAST(document_number AS string)   AS document_number
    , CAST(document_name AS string)     AS document_name
    , CAST(document_date AS date)       AS document_date
    , CAST(document_category AS string) AS document_category
    , CAST(file_path AS string)         AS file_path
    , CAST(file_name AS string)         AS file_name
    , CAST(file_size AS decimal(19,0))  AS file_size
    , CAST(sort_order AS int)           AS sort_order
    , CAST(created_at AS date)          AS created_at
    , CAST(last_modified_at AS date)    AS last_modified_at
    , CAST(created_by AS string)        AS created_by
    , CAST(last_modified_by AS string)  AS last_modified_by
    , CAST(version AS bigint)           AS version
    , CAST(deleted AS int)              AS deleted
    , CAST(content_type AS string)      AS content_type
FROM {{ source('source_thanhtra', 'raw_document_attachment') }}