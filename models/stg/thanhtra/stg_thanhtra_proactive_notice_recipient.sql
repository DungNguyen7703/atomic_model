/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_proactive_notice_recipient
* Program name: Staging THANHTRA.PROACTIVE_NOTICE_RECIPIENT
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
    , CAST(proactive_notice_id AS string) AS proactive_notice_id
    , CAST(company_code AS string)        AS company_code
    , CAST(company_name AS string)        AS company_name
    , CAST(company_type AS string)        AS company_type
    , CAST(confirmation_status AS string) AS confirmation_status
    , CAST(confirmed_at AS timestamp)     AS confirmed_at
    , CAST(confirmed_by AS string)        AS confirmed_by
    , CAST(push_status AS string)         AS push_status
    , CAST(push_error AS string)          AS push_error
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS bigint)             AS version
    , CAST(deleted AS int)                AS deleted
    , CAST(fms_event_id AS string)        AS fms_event_id
FROM {{ source('source_thanhtra', 'raw_proactive_notice_recipient') }}