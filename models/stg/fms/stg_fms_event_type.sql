/*
*--------------------------------------------------------------------*
* Program code: stg_fms_event_type
* Program name: Staging FMS.EVENT_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                AS id
    , CAST(category AS string)             AS category
    , CAST(item_name AS string)            AS item_name
    , CAST(record_status AS int)           AS record_status
    , CAST(description AS string)          AS description
    , CAST(note AS string)                 AS note
    , CAST(metadata AS string)             AS metadata
    , CAST(deleted AS int)                 AS deleted
    , CAST(date_created AS timestamp)      AS date_created
    , CAST(created_by AS string)           AS created_by
    , CAST(date_modified AS timestamp)     AS date_modified
    , CAST(modify_by AS string)            AS modify_by
    , CAST(event_code AS string)           AS event_code
    , CAST(event_category AS string)       AS event_category
    , CAST(obligation_type AS string)      AS obligation_type
    , CAST(deadline_calc_method AS string) AS deadline_calc_method
    , CAST(business_rule_config AS string) AS business_rule_config
FROM {{ source('source_fms', 'raw_event_type') }}