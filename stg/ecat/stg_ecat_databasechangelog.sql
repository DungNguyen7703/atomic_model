/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_databasechangelog
* Program name: Staging ECAT.DATABASECHANGELOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                AS id
    , CAST(author AS string)          AS author
    , CAST(filename AS string)        AS filename
    , CAST(dateexecuted AS timestamp) AS dateexecuted
    , CAST(orderexecuted AS int)      AS orderexecuted
    , CAST(exectype AS string)        AS exectype
    , CAST(md5sum AS string)          AS md5sum
    , CAST(description AS string)     AS description
    , CAST(comments AS string)        AS comments
    , CAST(tag AS string)             AS tag
    , CAST(liquibase AS string)       AS liquibase
    , CAST(contexts AS string)        AS contexts
    , CAST(labels AS string)          AS labels
    , CAST(deployment_id AS string)   AS deployment_id
FROM {{ source('source_ecat', 'raw_databasechangelog') }}