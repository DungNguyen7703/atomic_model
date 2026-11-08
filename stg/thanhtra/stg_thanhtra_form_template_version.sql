/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_form_template_version
* Program name: Staging THANHTRA.FORM_TEMPLATE_VERSION
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
    , CAST(form_template_id AS string) AS form_template_id
    , CAST(version_number AS bigint)   AS version_number
    , CAST(file_path AS string)        AS file_path
    , CAST(file_name AS string)        AS file_name
    , CAST(file_size AS decimal(19,0)) AS file_size
    , CAST(created_at AS date)         AS created_at
    , CAST(last_modified_at AS date)   AS last_modified_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(version AS bigint)          AS version
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_thanhtra', 'raw_form_template_version') }}