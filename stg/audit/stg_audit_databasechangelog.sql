/*
*--------------------------------------------------------------------*
* Program code: stg_audit_databasechangelog
* Program name: Staging AUDIT.DATABASECHANGELOG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo GMS_AUDIT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
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
FROM {{ source('source_audit', 'raw_databasechangelog') }}