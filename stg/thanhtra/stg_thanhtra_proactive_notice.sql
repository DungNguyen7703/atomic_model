/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_proactive_notice
* Program name: Staging THANHTRA.PROACTIVE_NOTICE
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
    , CAST(title AS string)               AS title
    , CAST(content AS string)             AS content
    , CAST(notice_type AS string)         AS notice_type
    , CAST(priority AS string)            AS priority
    , CAST(sender_id AS string)           AS sender_id
    , CAST(sender_name AS string)         AS sender_name
    , CAST(sent_at AS timestamp)          AS sent_at
    , CAST(status AS string)              AS status
    , CAST(attachment_ids_json AS string) AS attachment_ids_json
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS bigint)             AS version
    , CAST(deleted AS int)                AS deleted
FROM {{ source('source_thanhtra', 'raw_proactive_notice') }}