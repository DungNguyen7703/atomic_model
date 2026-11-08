/*
*--------------------------------------------------------------------*
* Program code: stg_fms_other_agent_history
* Program name: Staging FMS.OTHER_AGENT_HISTORY
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
    , HEX(other_agent_id)                  AS other_agent_id
    , CAST(event_name AS string)           AS event_name
    , CAST(license_amendment_no AS string) AS license_amendment_no
    , CAST(approval_date AS date)          AS approval_date
    , CAST(amendment_reason AS string)     AS amendment_reason
    , CAST(change_detail AS string)        AS change_detail
    , CAST(date_created AS timestamp)      AS date_created
    , CAST(created_by AS string)           AS created_by
    , CAST(date_modified AS timestamp)     AS date_modified
    , CAST(modify_by AS string)            AS modify_by
FROM {{ source('source_fms', 'raw_other_agent_history') }}