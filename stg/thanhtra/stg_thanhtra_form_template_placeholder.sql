/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_form_template_placeholder
* Program name: Staging THANHTRA.FORM_TEMPLATE_PLACEHOLDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(form_template_version_id AS string) AS form_template_version_id
    , CAST(placeholder_key AS string)          AS placeholder_key
    , CAST(placeholder_label AS string)        AS placeholder_label
    , CAST(data_type AS string)                AS data_type
    , CAST(required AS int)                    AS required
    , CAST(default_value AS string)            AS default_value
    , CAST(sort_order AS int)                  AS sort_order
    , CAST(created_at AS date)                 AS created_at
    , CAST(last_modified_at AS date)           AS last_modified_at
    , CAST(created_by AS string)               AS created_by
    , CAST(last_modified_by AS string)         AS last_modified_by
    , CAST(version AS bigint)                  AS version
    , CAST(deleted AS int)                     AS deleted
    , CAST(api_binding_path AS string)         AS api_binding_path
FROM {{ source('source_thanhtra', 'raw_form_template_placeholder') }}