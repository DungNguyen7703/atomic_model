/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_document_template_key_assign
* Program name: Staging THANHTRA.DOCUMENT_TEMPLATE_KEY_ASSIGN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(template_id AS string)         AS template_id
    , CAST(key_definition_id AS string)   AS key_definition_id
    , CAST(created_at AS date)            AS created_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS bigint)             AS version
    , CAST(deleted AS int)                AS deleted
    , CAST(template_version_id AS string) AS template_version_id
FROM {{ source('source_thanhtra', 'raw_document_template_key_assign') }}