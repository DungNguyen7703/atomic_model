/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_document_template_key_definition
* Program name: Staging THANHTRA.DOCUMENT_TEMPLATE_KEY_DEFINITION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(key_code AS string)                AS key_code
    , CAST(template_type AS string)           AS template_type
    , CAST(created_at AS date)                AS created_at
    , CAST(created_by AS string)              AS created_by
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(last_modified_by AS string)        AS last_modified_by
    , CAST(version AS bigint)                 AS version
    , CAST(deleted AS int)                    AS deleted
    , CAST(key_kind AS string)                AS key_kind
    , CAST(official_letter_subtype AS string) AS official_letter_subtype
    , CAST(api_field_key AS string)           AS api_field_key
    , CAST(interaction_mode AS string)        AS interaction_mode
    , CAST(fallback_config_json AS string)    AS fallback_config_json
    , CAST(description AS string)             AS description
FROM {{ source('source_thanhtra', 'raw_document_template_key_definition') }}